/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST API under <root> (default /api/v1) — stateless data quality
/// services for integration and the dataset operations:
///
///   GET   /meta
///   POST  /validate                 {datasetId?, records}            check records against the rules (nothing stored)
///   POST  /profiles                 {records}                        profile records (nothing stored)
///   POST  /duplicates/detect        {records, matchFields, strategy?, threshold?}
///   POST  /addresses/cleanse        {line1, …} | {addresses: […], persist?}
///   GET   /datasets                                                  datasets with scorecards
///   GET   /datasets/{id}/scorecard
///   GET   /datasets/{id}/violations
///   POST  /datasets/{id}/records    {records, createDataset?, replaceExisting?, validate?} | text/csv
///   POST  /datasets/{id}/validate | /profile | /duplicates {matchFields, strategy?, threshold?}
///
/// A record is {id?, fields: {name: value} | ["name=value"], fieldValues: {…}}.
/// Errors answer {"error": {code, message, requestId, target}} with
/// 400/401/403/404/409/422/500.
module uim.platform.data_quality.presentation.http.controllers.dq_api;

import std.uuid : randomUUID;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

/// The state of one REST call.
struct ApiCall {
  RequestContext ctx;
  TenantId t;
  UserId actor;
  HTTPServerRequest req;
  Json body;
  string text; /// raw body (CSV import)

  string param(string name) @trusted {
    return req.params.get(name, "");
  }

  string contentType() @trusted {
    return req.headers.get("Content-Type", "");
  }
}

class DqApiController {
  protected DqPorts ports;
  protected SecuritySetup security;
  protected string root;
  protected string serviceVersion;
  protected size_t maxBody;

  this(DqPorts ports, SecuritySetup security, string root = "/api/v1", string serviceVersion = "2.0.0",
    size_t maxBody = 16 * 1024 * 1024) {
    this.ports = ports;
    this.security = security;
    this.root = "/" ~ root.strip("/");
    this.serviceVersion = serviceVersion;
    this.maxBody = maxBody;
  }

  void registerRoutes(URLRouter router) {
    get(router, root ~ "/meta", (ref ApiCall c) => meta());

    post(router, root ~ "/validate", (ref ApiCall c) {
      auto results = ports.validation.validateInline(c.t, str(c.body, "datasetId"), recordsOf(c.body));
      auto rows = Json.emptyArray;
      size_t invalid;
      foreach (r; results) {
        rows ~= recordCheckJson(r.recordId, r.check);
        if (r.check.findings.length)
          invalid++;
      }
      return Json(["results": rows, "records": Json(results.length), "valid": Json(results.length - invalid),
          "invalid": Json(invalid)]);
    });

    post(router, root ~ "/profiles", (ref ApiCall c) {
      auto records = recordsOf(c.body);
      auto columns = Json.emptyArray;
      foreach (s; ports.profiling.profileInline(records))
        columns ~= columnStatsJson(s);
      return Json(["records": Json(records.length), "columns": columns]);
    });

    post(router, root ~ "/duplicates/detect", (ref ApiCall c) {
      auto threshold = "threshold" in c.body ? doubleOf(c.body, "threshold", 85) : 85.0;
      auto groups = ports.duplicates.detectInline(recordsOf(c.body), textsOf(c.body, "matchFields"),
        str(c.body, "strategy"), threshold);
      auto rows = Json.emptyArray;
      foreach (g; groups)
        rows ~= detectedGroupJson(g);
      return Json(["groups": rows, "count": Json(groups.length)]);
    });

    post(router, root ~ "/addresses/cleanse", (ref ApiCall c) {
      Json[] inputs;
      if ("addresses" in c.body && c.body["addresses"].type == Json.Type.array)
        inputs = (() @trusted => c.body["addresses"].get!(Json[]))();
      else
        inputs = [c.body];
      auto persist = boolOf(c.body, "persist", true);
      auto rows = Json.emptyArray;
      foreach (a; inputs) {
        if (!a.isObject)
          throw DataQualityException.invalid("An address must be a JSON object");
        auto r = cleanseAddressRequest(c.ctx, a, "");
        r.persist = persist;
        rows ~= addressRow(ports.addresses.cleanseAddress(r));
      }
      return Json(["results": rows, "count": Json(rows.length)]);
    });

    get(router, root ~ "/datasets", (ref ApiCall c) {
      auto counts = datasetCounts(ports, c.t);
      auto rows = Json.emptyArray;
      foreach (d; ports.datasets.listDatasets(c.t))
        rows ~= datasetRow(d, counts.get(d.id.value, DatasetCounts.init));
      return Json(["count": Json(rows.length), "resources": rows]);
    });

    get(router, root ~ "/datasets/:id/scorecard", (ref ApiCall c) {
      auto ds = DatasetId(c.param("id"));
      ports.datasets.getDataset(c.t, ds);
      return scorecardRow(ports.scorecards.currentScorecard(c.t, ds));
    });

    get(router, root ~ "/datasets/:id/violations", (ref ApiCall c) {
      auto ds = DatasetId(c.param("id"));
      ports.datasets.getDataset(c.t, ds);
      auto rows = Json.emptyArray;
      foreach (v; ports.validation.listViolations(c.t, ds))
        rows ~= violationRow(v);
      return Json(["count": Json(rows.length), "resources": rows]);
    });

    post(router, root ~ "/datasets/:id/records", (ref ApiCall c) {
      ImportRecordsRequest r;
      r.tenantId = c.t;
      r.actor = c.actor;
      r.datasetId = DatasetId(c.param("id"));
      if (c.contentType.startsWith("text/csv")) {
        r.records = parseCsvRecords(c.text);
        auto q = (() @trusted => c.req.query)();
        r.createDataset = ["true", "1", "yes"].canFind(q.get("createDataset", "").toLower);
        r.replaceExisting = !["false", "0", "no"].canFind(q.get("replaceExisting", "").toLower);
        r.validate = !["false", "0", "no"].canFind(q.get("validate", "").toLower);
      } else {
        r.records = recordsOf(c.body);
        r.createDataset = boolOf(c.body, "createDataset");
        r.replaceExisting = boolOf(c.body, "replaceExisting", true);
        r.validate = boolOf(c.body, "validate", true);
      }
      return importRow(ports.records.importRecords(r));
    });

    post(router, root ~ "/datasets/:id/validate", (ref ApiCall c) => validationRunRow(
        ports.validation.validateDataset(c.t, DatasetId(c.param("id")), c.actor)));
    post(router, root ~ "/datasets/:id/profile", (ref ApiCall c) => profileRunRow(
        ports.profiling.profileDataset(c.t, DatasetId(c.param("id")), c.actor)));
    post(router, root ~ "/datasets/:id/duplicates", (ref ApiCall c) {
      auto p = c.body.clone;
      p["datasetId"] = c.param("id");
      return detectRow(ports.duplicates.detectDuplicates(detectRequest(c.ctx, p)));
    });
  }

  /// Records of a body: {records: [{id?, fields | fieldValues}]}.
  static InlineRecord[] recordsOf(Json body) @trusted {
    if ("records" !in body || body["records"].type != Json.Type.array)
      throw DataQualityException.invalid("Body must contain a 'records' array");
    InlineRecord[] records;
    foreach (i, item; body["records"].get!(Json[])) {
      if (!item.isObject)
        throw DataQualityException.invalid(format("records[%d] must be an object", i));
      InlineRecord r;
      r.id = "id" in item ? textOrNumber(item["id"]) : "recordId" in item ? textOrNumber(item["recordId"]) : "";
      auto f = "fields" in item ? item["fields"] : "fieldValues" in item ? item["fieldValues"] : Json.emptyObject;
      if (f.type == Json.Type.object) {
        string[string] map;
        foreach (k, v; f.get!(Json[string]))
          map[k] = textOrNumber(v);
        r.fields = fieldsFromMap(map);
      } else if (f.type == Json.Type.array)
        r.fields = fieldsOf(Json(["f": f]), "f");
      else
        throw DataQualityException.invalid(format("records[%d].fields must be an object or an array", i));
      records ~= r;
    }
    return records;
  }

  protected static string textOrNumber(Json v) @trusted {
    switch (v.type) {
    case Json.Type.string:
      return v.get!string;
    case Json.Type.null_, Json.Type.undefined:
      return "";
    default:
      return v.toString;
    }
  }

  protected static string str(Json j, string key) {
    return key in j && j[key].type == Json.Type.string ? j[key].get!string : "";
  }

  protected Json meta() {
    auto j = Json.emptyObject;
    j["service"] = "uim-data-quality";
    j["version"] = serviceVersion;
    j["ruleTypes"] = texts(domainEnumValues!RuleType);
    j["severities"] = texts(domainEnumValues!RuleSeverity);
    j["cleansingActions"] = texts(domainEnumValues!CleansingAction);
    j["matchStrategies"] = texts(domainEnumValues!MatchStrategy);
    j["dimensions"] = texts(domainEnumValues!QualityDimension);
    j["weights"] = Json(["completeness": Json(completenessWeight), "validity": Json(validityWeight),
        "uniqueness": Json(uniquenessWeight), "consistency": Json(consistencyWeight), "accuracy": Json(accuracyWeight)]);
    return j;
  }

  // ── routing ───────────────────────────────────────────────────────────────
  protected void get(URLRouter router, string path, Json delegate(ref ApiCall) @safe action) {
    router.get(path, (HTTPServerRequest req, HTTPServerResponse res) @safe {
      serve(req, res, false, readScope, 200, action);
    });
  }

  protected void post(URLRouter router, string path, Json delegate(ref ApiCall) @safe action) {
    router.post(path, (HTTPServerRequest req, HTTPServerResponse res) @safe {
      serve(req, res, true, manageScope, 200, action);
    });
  }

  protected void serve(HTTPServerRequest req, HTTPServerResponse res, bool withBody, string scope_, int okStatus,
    scope Json delegate(ref ApiCall) @safe action) @trusted {
    int status = okStatus;
    Json body;
    auto requestId = randomUUID.toString;
    try {
      ApiCall c;
      c.req = req;
      c.ctx = security.resolve(req, "rest");
      if (security.requireAuthentication && !c.ctx.authenticated) {
        status = 401;
        body = errorBody("401", "A valid bearer token is required", requestId, req.requestPath.toString);
      } else if (!security.permits(c.ctx, scope_)) {
        status = 403;
        body = errorBody("403", "Missing scope '" ~ scope_ ~ "'", requestId, req.requestPath.toString);
      } else {
        c.t = TenantId(c.ctx.tenantId);
        c.actor = UserId(c.ctx.actor);
        c.body = Json.emptyObject;
        if (withBody) {
          c.text = req.bodyReader.readAllUTF8(false, maxBody);
          if (!c.contentType.startsWith("text/csv"))
            c.body = parseBody(c.text);
        }
        body = action(c);
      }
    } catch (DataQualityException e) {
      final switch (e.kind) {
      case DqErrorKind.invalid:
        status = 400;
        break;
      case DqErrorKind.notFound:
        status = 404;
        break;
      case DqErrorKind.conflict:
        status = 409;
        break;
      case DqErrorKind.ruleViolation:
        status = 422;
        break;
      }
      body = errorBody(status.to!string, e.msg, requestId, req.requestPath.toString);
    } catch (Exception e) {
      status = 500;
      body = errorBody("500", "Internal error", requestId, req.requestPath.toString);
      logServiceEvent("error", "unhandled REST error", Json([
          "path": Json(req.requestPath.toString), "error": Json(e.msg), "requestId": Json(requestId)
        ]));
    }
    res.headers["Cache-Control"] = "no-store";
    res.writeJsonBody(body, status);
  }

  static Json parseBody(string text) @trusted {
    if (text.strip.length == 0)
      return Json.emptyObject;
    Json j;
    try
      j = parseJsonString(text);
    catch (Exception e)
      throw DataQualityException.invalid("Request body is not valid JSON: " ~ e.msg);
    if (!j.isObject)
      throw DataQualityException.invalid("Request body must be a JSON object");
    return j;
  }

  static Json errorBody(string code, string message, string requestId, string target) {
    auto e = Json.emptyObject;
    e["code"] = code;
    e["message"] = message;
    e["requestId"] = requestId;
    e["target"] = target;
    return Json(["error": e]);
  }
}
