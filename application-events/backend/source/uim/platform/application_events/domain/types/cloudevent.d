/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A business event in the CloudEvents 1.0 format (the envelope SAP Cloud
/// Application Event Hub distributes). "source" is the id of the producing
/// system registration; "data" is any JSON value.
///
/// Filter attributes: id, type, source, subject, datacontenttype, time and
/// "data.<path>" (dot separated members of a JSON object data, e.g.
/// "data.country" or "data.address.city"; array items by index "data.items.0").
module uim.platform.application_events.domain.types.cloudevent;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

enum string cloudEventsSpecVersion = "1.0";
enum size_t maxSubjectLength = 500;

struct CloudEvent {
  string specVersion = cloudEventsSpecVersion;
  string id;
  string type;
  string source;
  string subject;
  long time; /// std time; 0 = not given
  string dataContentType = "application/json";
  Json data; /// undefined / null = no data

  /// The payload as compact JSON text ("" without data).
  string dataText() const @trusted {
    auto d = cast(Json) data;
    if (d.type == Json.Type.undefined || d.type == Json.Type.null_)
      return "";
    return d.toString;
  }

  /// Size of the payload in bytes (the limit of channels applies to it).
  size_t sizeBytes() const {
    return dataText.length;
  }

  /// Value of a filter attribute; found = false if it does not exist.
  string attribute(string name, out bool found) const @trusted {
    found = true;
    switch (name.strip.toLower) {
    case "id":
      return id;
    case "type":
      return type;
    case "source":
      return source;
    case "subject":
      found = subject.length > 0;
      return subject;
    case "datacontenttype":
      return dataContentType;
    case "time":
      found = time > 0;
      return isoTimeText(time);
    case "specversion":
      return specVersion;
    default:
      break;
    }
    auto n = name.strip;
    if (!n.startsWith("data.") && n != "data") {
      found = false;
      return "";
    }
    Json current = cast(Json) data;
    foreach (part; n.split(".")[1 .. $]) {
      if (current.type == Json.Type.object && part in current)
        current = current[part];
      else if (current.type == Json.Type.array && part.length && part.all!(c => c >= '0' && c <= '9')
        && part.to!size_t < current.length)
        current = current[part.to!size_t];
      else {
        found = false;
        return "";
      }
    }
    switch (current.type) {
    case Json.Type.undefined, Json.Type.null_:
      found = false;
      return "";
    case Json.Type.string:
      return current.get!string;
    case Json.Type.bool_:
      return current.get!bool ? "true" : "false";
    default:
      return current.toString;
    }
  }

  /// Structured mode JSON (application/cloudevents+json).
  Json toJson() const @trusted {
    auto j = Json.emptyObject;
    j["specversion"] = specVersion;
    j["id"] = id;
    j["type"] = type;
    j["source"] = source;
    if (subject.length)
      j["subject"] = subject;
    if (time > 0)
      j["time"] = isoTimeText(time);
    j["datacontenttype"] = dataContentType;
    auto d = cast(Json) data;
    if (d.type != Json.Type.undefined && d.type != Json.Type.null_)
      j["data"] = d;
    return j;
  }

  /// CloudEvents rules: specversion 1.0, id, source and a valid type.
  void validate() const {
    if (specVersion != cloudEventsSpecVersion)
      throw AehException.invalid("specversion '" ~ specVersion ~ "' is not supported (use 1.0)");
    requireText(id, "Event id");
    requireMaxLength(id, 200, "Event id");
    requireText(source, "Event source (the producing system)");
    requireMaxLength(subject, maxSubjectLength, "Subject");
    requireEventType(type);
    requireMaxLength(dataContentType, 200, "datacontenttype");
  }
}

/// Read a structured mode CloudEvent (unknown extension attributes are ignored).
/// The id is generated if missing; data may be a JSON value or, with
/// "data_base64", is refused (binary payloads are not supported).
CloudEvent parseCloudEvent(Json j) @trusted {
  if (!j.isObject)
    throw AehException.invalid("An event must be a JSON object");
  string text(string key) {
    if (key !in j || j[key].type == Json.Type.null_)
      return "";
    if (j[key].type != Json.Type.string)
      throw AehException.invalid("Event attribute '" ~ key ~ "' must be a string");
    return j[key].get!string;
  }

  if ("data_base64" in j)
    throw AehException.invalid("Binary payloads (data_base64) are not supported");
  CloudEvent e;
  auto sv = text("specversion");
  if (sv.length)
    e.specVersion = sv;
  e.id = text("id").strip;
  if (e.id.length == 0)
    e.id = newResourceId();
  e.type = text("type").strip;
  e.source = text("source").strip;
  e.subject = text("subject").strip;
  e.time = parseIsoTime(text("time"), "Event time");
  auto ct = text("datacontenttype").strip;
  if (ct.length)
    e.dataContentType = ct;
  if ("data" in j)
    e.data = j["data"];
  e.validate();
  return e;
}

///
unittest {
  auto e = parseCloudEvent(Json([
      "type": Json("sap.s4.beh.businesspartner.v1.BusinessPartner.Created.v1"), "source": Json("s4"),
      "data": Json(["country": Json("DE"), "address": Json(["city": Json("Berlin")]), "vip": Json(true),
        "items": Json([Json("a"), Json("b")])])
    ]));
  assert(e.id.length == 16 && e.specVersion == "1.0" && e.source == "s4");
  bool found;
  assert(e.attribute("data.country", found) == "DE" && found);
  assert(e.attribute("data.address.city", found) == "Berlin" && found);
  assert(e.attribute("data.vip", found) == "true" && found);
  assert(e.attribute("data.items.1", found) == "b" && found);
  e.attribute("data.missing", found);
  assert(!found);
  e.attribute("subject", found);
  assert(!found);
  assert(e.attribute("type", found).endsWith("Created.v1") && found);
  assert(e.toJson()["data"]["country"].get!string == "DE" && e.sizeBytes > 10);
  assert(failsWith(AehErrorKind.invalid, () { parseCloudEvent(Json(["type": Json("a.b")])); }));
  assert(failsWith(AehErrorKind.invalid, () { parseCloudEvent(Json(["type": Json("a b"), "source": Json("s")])); }));
  assert(failsWith(AehErrorKind.invalid, () {
      parseCloudEvent(Json(["type": Json("a.b"), "source": Json("s"), "specversion": Json("0.3")]));
    }));
}
