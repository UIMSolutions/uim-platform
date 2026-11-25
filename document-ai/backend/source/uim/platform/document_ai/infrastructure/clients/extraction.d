/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Adapters of the IExtractionEngine port.
///
///   simulate  (default) no OCR / model: deterministic, plausible values per
///             field type and name (amounts add up: line items → net, tax,
///             gross). Labels "<field>=<value>" are recognized with high
///             confidence (e.g. "senderName=ACME Corp"); the label
///             "simulate=failure" lets the extraction fail.
///   http      POSTs the document metadata and the schema fields as JSON to
///             extractionUrl and reads {"fields":[{name, scope?, rowIndex?,
///             value, confidence?, page?, coordinates?}], "pageCount"?}.
///             The Authorization header comes from the environment variable
///             DOCAI_EXTRACTION_AUTHORIZATION (never stored in the service).
module uim.platform.document_ai.infrastructure.clients.extraction;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

class SimulatedExtractionEngine : IExtractionEngine {
  string mode() {
    return "simulate";
  }

  ExtractionOutput extract(ExtractionRequest r) {
    ExtractionOutput o;
    auto started = nowStdTime();
    if (pairValue(r.document.labels, "simulate") == "failure") {
      o.message = "Simulated failure: the document could not be read (OCR quality too low)";
      return o;
    }
    auto doc = r.document;
    auto seed = doc.id.value ~ "|" ~ doc.fileName;
    double boost = doc.extractionMethod == ExtractionMethod.templateBased ? 0.12
      : doc.extractionMethod == ExtractionMethod.hybrid ? 0.08 : doc.extractionMethod == ExtractionMethod.generativeAi ? 0.05 : 0;
    if (!r.template_.isNull && r.template_.isActive)
      boost = max(boost, 0.12);

    double confidenceOf(string key) {
      return min(0.99, 0.55 + (fnvHash(seed ~ key) % 45) / 100.0 + boost);
    }

    // line items first: their amounts make up the header totals
    auto lineFields = r.fields.filter!(f => f.fieldScope == FieldScope.lineItem).array;
    int rows = lineFields.length ? cast(int)(1 + fnvHash(seed ~ "rows") % 4) : 0;
    double net = 0;
    foreach (row; 1 .. rows + 1) {
      auto q = cast(long)(1 + fnvHash(seed ~ "q" ~ row.to!string) % 20);
      auto price = (500 + fnvHash(seed ~ "p" ~ row.to!string) % 49_500) / 100.0;
      auto lineNet = q * price;
      net += lineNet;
      foreach (i, f; lineFields) {
        ExtractedValue v;
        v.name = f.name;
        v.fieldScope = FieldScope.lineItem;
        v.rowIndex = row;
        auto key = f.name ~ "#" ~ row.to!string;
        v.confidence = confidenceOf(key);
        v.page = 1 + (row - 1) % max(1, doc.pageCount);
        v.coordinates = format("0.%02d,0.%02d,0.15,0.02", 5 + i * 15 % 90, 40 + row * 5 % 50);
        switch (f.name.toLower) {
        case "quantity":
          v.value = q.to!string;
          break;
        case "unitprice", "price":
          v.value = format("%.2f", price);
          break;
        case "netamount", "amount", "total":
          v.value = format("%.2f", lineNet);
          break;
        default:
          v.value = simulatedValue(f, seed ~ key, doc);
        }
        o.values ~= v;
      }
    }
    if (rows == 0)
      net = (10_000 + fnvHash(seed ~ "net") % 990_000) / 100.0;
    auto tax = net * 0.19;

    foreach (i, f; r.fields.filter!(f => f.fieldScope == FieldScope.header).array) {
      ExtractedValue v;
      v.name = f.name;
      v.page = 1;
      v.coordinates = format("0.%02d,0.%02d,0.30,0.03", 55 + i * 7 % 40, 5 + i * 6 % 80);
      auto hint = pairValue(doc.labels, f.name);
      if (hint.length) {
        v.value = hint;
        v.confidence = 0.97;
        o.values ~= v;
        continue;
      }
      // every 13th unguided value is not found — that is what the review is for
      if (fnvHash(seed ~ "missing" ~ f.name) % 13 == 0)
        continue;
      v.confidence = confidenceOf(f.name);
      switch (f.name.toLower) {
      case "netamount":
        v.value = format("%.2f", net);
        break;
      case "taxamount":
        v.value = format("%.2f", tax);
        break;
      case "grossamount", "totalamount", "total":
        v.value = format("%.2f", net + tax);
        break;
      default:
        v.value = simulatedValue(f, seed ~ f.name, doc);
      }
      o.values ~= v;
    }
    o.success = true;
    o.message = format("Simulated extraction: %d values, %d line items", o.values.length, rows);
    o.durationMs = millisBetween(started, nowStdTime());
    return o;
  }
}

class HttpExtractionEngine : IExtractionEngine {
  protected string url;
  protected Duration timeout;
  protected size_t maxResponseBytes = 4 * 1024 * 1024;

  this(string url, uint timeoutSeconds) {
    this.url = url.strip;
    this.timeout = dur!"seconds"(timeoutSeconds > 0 ? timeoutSeconds : 60);
  }

  string mode() {
    return "http";
  }

  ExtractionOutput extract(ExtractionRequest r) @trusted {
    import std.process : environment;
    import vibe.http.client : requestHTTP, HTTPClientSettings, HTTPClientRequest, HTTPClientResponse;
    import vibe.http.common : HTTPMethod;

    ExtractionOutput o;
    auto started = nowStdTime();
    try {
      auto body = requestBody(r).toString;
      auto settings = new HTTPClientSettings;
      settings.connectTimeout = timeout;
      settings.readTimeout = timeout;
      settings.defaultKeepAliveTimeout = 0.seconds;
      auto auth = environment.get("DOCAI_EXTRACTION_AUTHORIZATION", "");
      int status;
      string text;
      requestHTTP(url, (scope HTTPClientRequest req) {
        req.method = HTTPMethod.POST;
        req.headers["Accept"] = "application/json";
        req.headers["X-Correlation-Id"] = r.document.id.value;
        if (auth.length)
          req.headers["Authorization"] = auth;
        req.writeBody(cast(const(ubyte)[]) body, "application/json");
      }, (scope HTTPClientResponse res) {
        status = res.statusCode;
        ubyte[8192] buffer;
        while (!res.bodyReader.empty && text.length < maxResponseBytes) {
          auto n = min(cast(size_t) res.bodyReader.leastSize, buffer.length);
          res.bodyReader.read(buffer[0 .. n]);
          text ~= cast(string) buffer[0 .. n].idup;
        }
        if (!res.bodyReader.empty)
          res.disconnect();
      }, settings);
      if (status < 200 || status >= 300)
        o.message = format("Extraction service answered HTTP %d: %s", status, text.length > 500 ? text[0 .. 500] : text);
      else
        o = parseResponse(text);
    } catch (Exception e) {
      o.success = false;
      o.message = "Extraction service failed: " ~ e.msg;
    }
    o.durationMs = millisBetween(started, nowStdTime());
    return o;
  }

  static Json requestBody(const ExtractionRequest r) {
    auto doc = Json.emptyObject;
    doc["id"] = r.document.id.value;
    doc["fileName"] = r.document.fileName;
    doc["fileType"] = cast(string) r.document.fileType;
    doc["mimeType"] = r.document.mimeType;
    doc["language"] = r.document.language;
    doc["pageCount"] = r.document.pageCount;
    doc["extractionMethod"] = cast(string) r.document.extractionMethod;
    auto labels = Json.emptyArray;
    foreach (l; r.document.labels)
      labels ~= Json(l);
    doc["labels"] = labels;
    auto fields = Json.emptyArray;
    foreach (f; r.fields) {
      auto j = Json.emptyObject;
      j["name"] = f.name;
      j["label"] = f.label;
      j["scope"] = cast(string) f.fieldScope;
      j["type"] = cast(string) f.valueType;
      j["required"] = f.required;
      j["description"] = f.description;
      fields ~= j;
    }
    auto b = Json.emptyObject;
    b["tenantId"] = r.tenantId.value;
    b["document"] = doc;
    b["schema"] = Json(["id": Json(r.schema.id.value), "name": Json(r.schema.name)]);
    b["fields"] = fields;
    if (!r.template_.isNull)
      b["template"] = Json(["id": Json(r.template_.id.value), "senderName": Json(r.template_.senderName)]);
    return b;
  }

  static ExtractionOutput parseResponse(string text) @trusted {
    ExtractionOutput o;
    Json j;
    try
      j = parseJsonString(text);
    catch (Exception e) {
      o.message = "Extraction service answered no JSON: " ~ e.msg;
      return o;
    }
    if (!j.isObject || "fields" !in j || j["fields"].type != Json.Type.array) {
      o.message = "Extraction service answered no 'fields' array";
      return o;
    }
    foreach (item; j["fields"].get!(Json[])) {
      if (!item.isObject)
        continue;
      ExtractedValue v;
      v.name = textField(item, "name");
      if (v.name.length == 0)
        continue;
      v.fieldScope = domainEnumOr!FieldScope(textField(item, "scope"), FieldScope.header);
      v.rowIndex = cast(int) longField(item, "rowIndex", v.fieldScope == FieldScope.lineItem ? 1 : 0);
      if (v.fieldScope == FieldScope.header)
        v.rowIndex = 0;
      else if (v.rowIndex < 1)
        v.rowIndex = 1;
      auto value = "value" in item ? item["value"] : Json(null);
      v.value = value.type == Json.Type.string ? value.get!string : value.type == Json.Type.null_
        || value.type == Json.Type.undefined ? "" : value.toString;
      v.confidence = doubleField(item, "confidence", 0.5);
      v.page = cast(int) longField(item, "page", 1);
      v.coordinates = textField(item, "coordinates");
      o.values ~= v;
    }
    o.pageCount = cast(int) longField(j, "pageCount", 0);
    o.success = true;
    o.message = format("%d values from the extraction service", o.values.length);
    return o;
  }
}

// ── simulation helpers ───────────────────────────────────────────────────
/// FNV-1a (stable across runs and platforms).
ulong fnvHash(string text) pure nothrow {
  ulong h = 14_695_981_039_346_656_037UL;
  foreach (c; cast(const(ubyte)[]) text) {
    h ^= c;
    h *= 1_099_511_628_211UL;
  }
  return h;
}

private enum string[] companies = ["ACME Corp", "Globex GmbH", "Initech AG", "Umbrella Ltd", "Stark Industries", "Wayne Enterprises"];
private enum string[] cities = ["Berlin", "Hamburg", "Munich", "Cologne", "Frankfurt", "Vienna", "Zurich"];
private enum string[] items = ["Office chairs", "Laptop docking station", "Consulting services", "Maintenance fee",
    "Printer toner", "Cloud subscription", "Shipping and handling", "Safety gloves"];

private string simulatedValue(const SchemaField f, string key, const AiDocument doc) {
  auto h = fnvHash(key);
  auto name = f.name.toLower;
  auto day = doc.createdAt > 0 ? doc.createdAt : nowStdTime();
  final switch (f.valueType) {
  case FieldValueType.date:
    if (name.canFind("due"))
      return isoDateText(plusDays(day, 30));
    if (name.canFind("deliver"))
      return isoDateText(plusDays(day, 14));
    return isoDateText(plusDays(day, -cast(long)(h % 5)));
  case FieldValueType.currency:
    return "EUR";
  case FieldValueType.boolean:
    return h % 2 ? "true" : "false";
  case FieldValueType.address:
    return format("%s %d, %05d %s", ["Hauptstraße", "Marktplatz", "Industriestraße", "Am Hafen"][h % 4], 1 + h % 120,
      10_000 + h % 89_999, cities[h % cities.length]);
  case FieldValueType.number:
    if (name.canFind("quantity"))
      return (1 + h % 20).to!string;
    return format("%.2f", (100 + h % 99_900) / 100.0);
  case FieldValueType.text:
    if (name.canFind("sender") && name.canFind("city") || name.canFind("city"))
      return cities[h % cities.length];
    if (name.canFind("sender") || name.canFind("supplier") || name.canFind("merchant") || name.canFind("customer")
      || name.canFind("vendor"))
      return companies[h % companies.length];
    if (name.canFind("purchaseorder"))
      return format("45000%05d", h % 100_000);
    if (name == "documentnumber" || name.canFind("invoice") || name.canFind("number")) {
      if (name.canFind("material"))
        return format("MAT-%04d", h % 10_000);
      auto prefix = doc.fileName.toLower.startsWith("po") ? "PO-" : "INV-";
      return format("%s%04d-%04d", prefix, 2026, h % 10_000);
    }
    if (name.canFind("material"))
      return format("MAT-%04d", h % 10_000);
    if (name.canFind("description") || name.canFind("item"))
      return items[h % items.length];
    return format("%s %d", f.label.length ? f.label : f.name, h % 1000);
  }
}

///
unittest {
  auto engine = new SimulatedExtractionEngine;
  ExtractionRequest r;
  r.document.id = DocumentId("d1");
  r.document.fileName = "inv.pdf";
  r.document.labels = ["senderName=ACME Corp"];
  SchemaField f(string name, FieldScope s, FieldValueType t) {
    SchemaField x;
    x.name = name;
    x.label = name;
    x.fieldScope = s;
    x.valueType = t;
    return x;
  }

  r.fields = [f("senderName", FieldScope.header, FieldValueType.text), f("grossAmount", FieldScope.header,
      FieldValueType.number), f("quantity", FieldScope.lineItem, FieldValueType.number),
    f("netAmount", FieldScope.lineItem, FieldValueType.number)];
  auto o = engine.extract(r);
  assert(o.success && o.values.length >= 3, o.to!string);
  auto sender = o.values.find!(v => v.name == "senderName").front;
  assert(sender.value == "ACME Corp" && sender.confidence == 0.97);
  assert(engine.extract(r).values == o.values); // deterministic
  r.document.labels = ["simulate=failure"];
  assert(!engine.extract(r).success);

  auto parsed = HttpExtractionEngine.parseResponse(`{"fields":[{"name":"a","value":"1","confidence":0.9},`
      ~ `{"name":"q","scope":"lineItem","rowIndex":2,"value":3}],"pageCount":2}`);
  assert(parsed.success && parsed.values.length == 2 && parsed.pageCount == 2);
  assert(parsed.values[1].rowIndex == 2 && parsed.values[1].value == "3" && parsed.values[0].rowIndex == 0);
  assert(!HttpExtractionEngine.parseResponse("nope").success);
  assert(HttpExtractionEngine.requestBody(r)["fields"].length == 4);
}
