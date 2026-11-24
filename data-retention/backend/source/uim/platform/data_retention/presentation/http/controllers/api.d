/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST API under <root>/data-retention (default /api/v1/data-retention).
/// Every call goes through the OData engine, so REST, OData, CLI and GUI
/// validate, authorize and answer alike.
///
///   GET    /<resource>[?$filter=…&$orderby=…&$top=…&$skip=…&$search=…]   → {count, resources}
///   GET    /<resource>/{id}
///   POST   /<resource>                                                  → 201
///   PUT    /<resource>/{id}      (also PATCH; partial update)
///   DELETE /<resource>/{id}                                             → 204
///
///   resources: application-groups, legal-entities, data-subject-roles,
///   business-purposes, legal-grounds, residence-rules, retention-rules,
///   data-subjects, deletion-requests, archiving-jobs
///
///   POST   /business-purposes/{id}/activate | /deactivate | /deprecate
///   POST   /data-subjects/{id}/block
///   POST   /data-subjects/{id}/legal-hold      {legalHold, reason}
///   GET    /data-subjects/{id}/evaluation
///   POST   /deletion-requests/{id}/process | /cancel
///   POST   /archiving-jobs/{id}/run | /cancel
///   POST   /end-of-purpose/check               {applicationGroupId?, simulate?}
///   POST   /simulate                           {businessPurposeId, referenceDate, legalGroundId?}
///   GET    /statistics
///   GET    /meta
///   POST   /demo-data
///
/// Errors answer {"error": {code, message, requestId, target}} with
/// 400/401/403/404/405/409/422/500.
module uim.platform.data_retention.presentation.http.controllers.api;

import std.uuid : randomUUID;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;
import uim.platform.service.presentation.odata.engine : ODataEngine;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

/// REST resource path → entity set.
enum string[string] restResources = [
    "application-groups": "ApplicationGroups", "legal-entities": "LegalEntities",
    "data-subject-roles": "DataSubjectRoles", "business-purposes": "BusinessPurposes",
    "legal-grounds": "LegalGrounds", "residence-rules": "ResidenceRules", "retention-rules": "RetentionRules",
    "data-subjects": "DataSubjects", "deletion-requests": "DeletionRequests", "archiving-jobs": "ArchivingJobs"
  ];

/// The state of one REST call.
struct ApiCall {
  RequestContext ctx;
  HTTPServerRequest req;
  Json body;
  int status = 200;

  string param(string name) @trusted {
    return req.params.get(name, "");
  }

  string[string] queryOptions() @trusted {
    string[string] o;
    foreach (k, v; req.query.byKeyValue)
      o[k] = v;
    return o;
  }
}

class DrApiController {
  protected ODataEngine engine;
  protected SecuritySetup security;
  protected string root;
  protected string serviceVersion;
  protected size_t maxBody;

  this(ODataEngine engine, SecuritySetup security, string apiPath = "/api/v1", string serviceVersion = "2.0.0",
    size_t maxBody = 4 * 1024 * 1024) {
    this.engine = engine;
    this.security = security;
    this.root = "/" ~ apiPath.strip("/") ~ "/data-retention";
    this.serviceVersion = serviceVersion;
    this.maxBody = maxBody;
  }

  void registerRoutes(URLRouter router) {
    route(router, "GET", "/meta", (ref ApiCall c) => meta());
    route(router, "GET", "/statistics", (ref ApiCall c) => engine.read(c.ctx, "Statistics", ""));
    route(router, "POST", "/end-of-purpose/check", (ref ApiCall c) => engine.invoke(c.ctx, "CheckEndOfPurpose",
        pick(c.body, "applicationGroupId", "simulate")));
    route(router, "POST", "/simulate", (ref ApiCall c) => engine.invoke(c.ctx, "SimulateRetention",
        pick(c.body, "businessPurposeId", "referenceDate", "legalGroundId")));
    route(router, "POST", "/demo-data", (ref ApiCall c) => engine.invoke(c.ctx, "SeedDemoData", Json.emptyObject));

    // operations on single resources
    operation(router, "business-purposes", "activate", "ActivateBusinessPurpose");
    operation(router, "business-purposes", "deactivate", "DeactivateBusinessPurpose");
    operation(router, "business-purposes", "deprecate", "DeprecateBusinessPurpose");
    operation(router, "data-subjects", "block", "BlockDataSubject");
    route(router, "POST", "/data-subjects/:id/legal-hold", (ref ApiCall c) {
      auto p = pick(c.body, "legalHold", "reason");
      p["id"] = c.param("id");
      if ("legalHold" !in p)
        p["legalHold"] = true;
      return engine.invoke(c.ctx, "SetLegalHold", p);
    });
    route(router, "GET", "/data-subjects/:id/evaluation", (ref ApiCall c) {
      auto row = engine.read(c.ctx, "DataSubjects", c.param("id"));
      auto e = Json.emptyObject;
      foreach (k; ["id", "lifecycleStatus", "legalHold", "referenceDate", "phase", "governingLegalGroundId",
          "governingLegalGroundName", "residence", "retention", "endOfPurpose", "endOfRetention", "actionOnExpiry",
          "daysToEndOfRetention", "dueForBlocking", "dueForDestruction", "retentionReason"])
        e[k] = row[k];
      return e;
    });
    operation(router, "deletion-requests", "process", "ProcessDeletionRequest");
    operation(router, "deletion-requests", "cancel", "CancelDeletionRequest");
    operation(router, "archiving-jobs", "run", "RunArchivingJob");
    operation(router, "archiving-jobs", "cancel", "CancelArchivingJob");

    // CRUD of every resource
    foreach (path, set; restResources)
      resource(router, path, set);
  }

  protected void resource(URLRouter router, string path, string set) {
    route(router, "GET", "/" ~ path, (ref ApiCall c) {
      auto page = engine.query(c.ctx, set, c.queryOptions);
      return Json(["count": Json(page.total), "resources": Json(page.rows)]);
    });
    route(router, "GET", "/" ~ path ~ "/:id", (ref ApiCall c) => engine.read(c.ctx, set, c.param("id")));
    route(router, "POST", "/" ~ path, (ref ApiCall c) {
      c.status = 201;
      return engine.create(c.ctx, set, c.body);
    });
    route(router, "PUT", "/" ~ path ~ "/:id", (ref ApiCall c) => engine.update(c.ctx, set, c.param("id"), c.body));
    route(router, "PATCH", "/" ~ path ~ "/:id", (ref ApiCall c) => engine.update(c.ctx, set, c.param("id"), c.body));
    route(router, "DELETE", "/" ~ path ~ "/:id", (ref ApiCall c) {
      engine.remove(c.ctx, set, c.param("id"));
      c.status = 204;
      return Json(null);
    });
  }

  protected void operation(URLRouter router, string path, string verb, string action) {
    route(router, "POST", "/" ~ path ~ "/:id/" ~ verb, (ref ApiCall c) => engine.invoke(c.ctx, action,
        Json(["id": Json(c.param("id"))])));
  }

  protected Json meta() {
    auto j = Json.emptyObject;
    j["service"] = "uim-data-retention";
    j["version"] = serviceVersion;
    j["security"] = security.mode;
    j["resources"] = texts(restResources.keys.sort.array);
    j["legalGroundTypes"] = texts(domainEnumValues!LegalGroundType);
    j["periodUnits"] = texts(domainEnumValues!PeriodUnit);
    j["deletionActions"] = texts(domainEnumValues!DeletionAction);
    j["lifecycleStatuses"] = texts(domainEnumValues!LifecycleStatus);
    j["retentionPhases"] = texts(domainEnumValues!RetentionPhase);
    j["archivingOperations"] = texts(domainEnumValues!ArchivingOperation);
    j["businessPurposeStatuses"] = texts(domainEnumValues!BusinessPurposeStatus);
    return j;
  }

  /// The listed members of a body (unknown ones would be refused by the engine).
  protected static Json pick(Json body, string[] names...) {
    auto j = Json.emptyObject;
    foreach (n; names)
      if (n in body && body[n].type != Json.Type.null_)
        j[n] = body[n];
    return j;
  }

  // ── routing ───────────────────────────────────────────────────────────────
  protected void route(URLRouter router, string method, string path, Json delegate(ref ApiCall) @safe action) {
    auto full = root ~ path;
    auto withBody = method == "POST" || method == "PUT" || method == "PATCH";
    auto handler = (HTTPServerRequest req, HTTPServerResponse res) @safe { serve(req, res, withBody, action); };
    switch (method) {
    case "GET":
      router.get(full, handler);
      break;
    case "POST":
      router.post(full, handler);
      break;
    case "PUT":
      router.put(full, handler);
      break;
    case "PATCH":
      router.patch(full, handler);
      break;
    case "DELETE":
      router.delete_(full, handler);
      break;
    default:
      assert(false, method);
    }
  }

  protected void serve(HTTPServerRequest req, HTTPServerResponse res, bool withBody,
    scope Json delegate(ref ApiCall) @safe action) @trusted {
    Json body;
    int status;
    auto requestId = randomUUID.toString;
    auto target = req.requestPath.toString;
    try {
      ApiCall c;
      c.req = req;
      c.ctx = security.resolve(req, "rest");
      if (security.requireAuthentication && !c.ctx.authenticated) {
        status = 401;
        body = errorBody("401", "A valid bearer token is required", requestId, target);
      } else {
        c.body = withBody ? parseBody(req.bodyReader.readAllUTF8(false, maxBody)) : Json.emptyObject;
        body = action(c);
        status = c.status;
      }
    } catch (EntitySetException e) {
      status = e.status;
      body = errorBody(e.status.to!string, e.msg, requestId, target);
    } catch (DataRetentionException e) {
      auto x = toEntitySetException(e);
      status = x.status;
      body = errorBody(x.status.to!string, e.msg, requestId, target);
    } catch (Exception e) {
      status = 500;
      body = errorBody("500", "Internal error", requestId, target);
      logServiceEvent("error", "unhandled REST error", Json([
          "path": Json(target), "error": Json(e.msg), "requestId": Json(requestId)
        ]));
    }
    res.headers["Cache-Control"] = "no-store";
    if (status == 204) {
      res.statusCode = 204;
      res.writeVoidBody();
    } else
      res.writeJsonBody(body, status);
  }

  static Json parseBody(string text) @trusted {
    if (text.strip.length == 0)
      return Json.emptyObject;
    Json j;
    try
      j = parseJsonString(text);
    catch (Exception e)
      throw DataRetentionException.invalid("Request body is not valid JSON: " ~ e.msg);
    if (!j.isObject)
      throw DataRetentionException.invalid("Request body must be a JSON object");
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
