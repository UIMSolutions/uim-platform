/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST API under <root>/document-ai (default /api/v1/document-ai). Every
/// call goes through the OData engine, so REST, OData, CLI and GUI
/// validate, authorize and answer alike.
///
///   GET    /<resource>[?$filter=…&$orderby=…&$top=…&$skip=…&$search=…]   → {count, resources}
///   GET    /<resource>/{id}
///   POST   /<resource>                                                  → 201
///   PUT    /<resource>/{id}      (also PATCH; partial update)
///   DELETE /<resource>/{id}                                             → 204
///
///   resources: documents, extracted-fields (PATCH: value), schemas,
///   schema-fields, templates, document-types, enrichment-data, clients,
///   training-jobs, users
///
///   POST   /documents/{id}/extract | /confirm
///   POST   /documents/{id}/reject              {reason}
///   GET    /documents/{id}/fields              values: header fields, then line items
///   POST   /documents/process                  extract the pending documents now
///   GET    /review                             documents that need a review
///   POST   /extracted-fields/{id}/correct      {value}
///   POST   /schemas/{id}/activate | /deprecate
///   POST   /schemas/{id}/copy                  {newId?}
///   GET    /schemas/{id}/fields
///   POST   /templates/{id}/activate | /deactivate
///   POST   /training-jobs/{id}/start | /cancel
///   GET    /statistics | /capabilities | /meta
///   POST   /demo-data
///
/// Errors answer {"error": {code, message, requestId, target}} with
/// 400/401/403/404/405/409/422/500.
module uim.platform.document_ai.presentation.http.controllers.api;

import std.uuid : randomUUID;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;
import uim.platform.service.presentation.odata.engine : ODataEngine;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

/// REST resource path → entity set.
enum string[string] restResources = [
    "documents": "Documents", "extracted-fields": "ExtractedFields", "schemas": "Schemas",
    "schema-fields": "SchemaFields", "templates": "Templates", "document-types": "DocumentTypes",
    "enrichment-data": "EnrichmentData", "clients": "Clients", "training-jobs": "TrainingJobs", "users": "Users"
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

class DaiApiController {
  protected ODataEngine engine;
  protected SecuritySetup security;
  protected string root;
  protected string serviceVersion;
  protected size_t maxBody;
  protected Json capabilities;

  this(ODataEngine engine, SecuritySetup security, string apiPath = "/api/v1", string serviceVersion = "2.0.0",
    size_t maxBody = 4 * 1024 * 1024, Json capabilities = Json.emptyObject) {
    this.engine = engine;
    this.security = security;
    this.root = "/" ~ apiPath.strip("/") ~ "/document-ai";
    this.serviceVersion = serviceVersion;
    this.maxBody = maxBody;
    this.capabilities = capabilities;
  }

  void registerRoutes(URLRouter router) {
    route(router, "GET", "/meta", (ref ApiCall c) => meta());
    route(router, "GET", "/capabilities", (ref ApiCall c) => capabilities);
    route(router, "GET", "/statistics", (ref ApiCall c) => engine.read(c.ctx, "Statistics", ""));
    route(router, "POST", "/demo-data", (ref ApiCall c) => engine.invoke(c.ctx, "SeedDemoData", Json.emptyObject));
    route(router, "POST", "/documents/process", (ref ApiCall c) => engine.invoke(c.ctx, "ProcessPendingDocuments",
        Json.emptyObject));
    route(router, "GET", "/review", (ref ApiCall c) {
      auto options = c.queryOptions;
      auto mine = "needsReview eq true";
      options["$filter"] = "$filter" in options ? "(" ~ options["$filter"] ~ ") and " ~ mine : mine;
      if ("$orderby" !in options)
        options["$orderby"] = "createdAt";
      return page(engine.query(c.ctx, "Documents", options));
    });
    // operations on single resources
    operation(router, "documents", "extract", "ExtractDocument");
    operation(router, "documents", "confirm", "ConfirmDocument");
    operation(router, "documents", "reject", "RejectDocument", "reason");
    operation(router, "extracted-fields", "correct", "CorrectField", "value");
    operation(router, "schemas", "activate", "ActivateSchema");
    operation(router, "schemas", "deprecate", "DeprecateSchema");
    operation(router, "schemas", "copy", "CopySchema", "newId");
    operation(router, "templates", "activate", "ActivateTemplate");
    operation(router, "templates", "deactivate", "DeactivateTemplate");
    operation(router, "training-jobs", "start", "StartTraining");
    operation(router, "training-jobs", "cancel", "CancelTraining");
    // children
    children(router, "documents", "fields", "ExtractedFields", "documentId", "rowIndex,sequenceNumber");
    children(router, "schemas", "fields", "SchemaFields", "schemaId", "fieldScope,sequenceNumber");
    // CRUD of every resource
    foreach (path, set; restResources)
      resource(router, path, set);
  }

  protected void resource(URLRouter router, string path, string set) {
    route(router, "GET", "/" ~ path, (ref ApiCall c) => page(engine.query(c.ctx, set, c.queryOptions)));
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

  /// POST /<path>/{id}/<verb> → action(id, picked body members)
  protected void operation(URLRouter router, string path, string verb, string action, string[] members...) {
    auto names = members.dup;
    route(router, "POST", "/" ~ path ~ "/:id/" ~ verb, (ref ApiCall c) {
      auto p = pick(c.body, names);
      p["id"] = c.param("id");
      return engine.invoke(c.ctx, action, p);
    });
  }

  /// GET /<path>/{id}/<child> → the child set filtered by its reference.
  protected void children(URLRouter router, string path, string child, string set, string reference, string orderBy) {
    route(router, "GET", "/" ~ path ~ "/:id/" ~ child, (ref ApiCall c) {
      auto id = c.param("id");
      if (!isValidId(id))
        throw DaiException.notFound("'" ~ id ~ "'");
      auto parent = restResources[path];
      engine.read(c.ctx, parent, id); // 404 for unknown parents
      auto options = c.queryOptions;
      auto filter = reference ~ " eq '" ~ id ~ "'";
      options["$filter"] = "$filter" in options ? "(" ~ options["$filter"] ~ ") and " ~ filter : filter;
      if ("$orderby" !in options)
        options["$orderby"] = orderBy;
      return page(engine.query(c.ctx, set, options));
    });
  }

  protected static Json page(ODataPage p) {
    return Json(["count": Json(p.total), "resources": Json(p.rows)]);
  }

  protected Json meta() {
    auto j = Json.emptyObject;
    j["service"] = "uim-document-ai";
    j["version"] = serviceVersion;
    j["security"] = security.mode;
    j["resources"] = texts(restResources.keys.sort.array);
    j["documentStatuses"] = texts(domainEnumValues!DocumentStatus);
    j["extractionMethods"] = texts(domainEnumValues!ExtractionMethod);
    j["documentCategories"] = texts(domainEnumValues!DocumentCategory);
    j["valueTypes"] = texts(domainEnumValues!FieldValueType);
    j["fieldScopes"] = texts(domainEnumValues!FieldScope);
    j["schemaStatuses"] = texts(domainEnumValues!SchemaStatus);
    j["templateStatuses"] = texts(domainEnumValues!TemplateStatus);
    j["trainingStatuses"] = texts(domainEnumValues!TrainingJobStatus);
    j["matchStatuses"] = texts(domainEnumValues!MatchStatus);
    j["enrichmentSubtypes"] = texts(domainEnumValues!EnrichmentSubtype);
    j["fileTypes"] = texts(domainEnumValues!FileType);
    j["confidenceLevels"] = texts(domainEnumValues!ConfidenceLevel);
    j["scopes"] = texts(knownScopes);
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
    } catch (DocumentAiException e) {
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
      throw DaiException.invalid("Request body is not valid JSON: " ~ e.msg);
    if (!j.isObject)
      throw DaiException.invalid("Request body must be a JSON object");
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
