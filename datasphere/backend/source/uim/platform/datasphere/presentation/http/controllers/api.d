/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST API under <root>/datasphere (default /api/v1/datasphere). Every
/// management call goes through the OData engine, so REST, OData, CLI and
/// GUI validate, authorize and answer alike.
///
///   GET    /<resource>[?$filter=…&$orderby=…&$top=…&$skip=…&$search=…]   → {count, resources}
///   GET    /<resource>/{id}
///   POST   /<resource>                                                  → 201
///   PUT    /<resource>/{id}      (also PATCH; partial update)
///   DELETE /<resource>/{id}                                             → 204
///
///   resources: spaces, members, connections, remote-tables, views,
///   data-flows, tasks, task-chains, runs (read only), access-controls,
///   catalog, users
///
///   POST   /spaces/{id}/lock {reason} | /unlock
///   GET    /spaces/{id}/members | connections | remote-tables | views | data-flows | tasks
///                    | task-chains | runs | access-controls | catalog
///   POST   /connections/{id}/validate
///   GET    /connections/{id}/remote-tables
///   POST   /remote-tables/{id}/replicate | /drop-replica
///   POST   /views/{id}/deploy | /persist | /remove-persistence
///   POST   /views/{id}/check-access {user, row: {column: value}}
///   POST   /data-flows/{id}/deploy | /run
///   POST   /tasks/{id}/run | /pause | /resume
///   GET    /tasks/{id}/runs
///   POST   /task-chains/{id}/run | /pause | /resume
///   GET    /task-chains/{id}/runs
///   GET    /runs/{id}/steps             the step runs of a task chain run
///   GET    /catalog/search?q=<text>[&space=<id>]   best matches first
///   POST   /scheduler/run               run the due tasks and task chains
///   POST   /runs/purge                  apply the run retention
///   GET    /statistics | /capabilities | /meta
///   POST   /demo-data
///
/// Errors answer {"error": {code, message, requestId, target}} with
/// 400/401/403/404/405/409/413/422/500.
module uim.platform.datasphere.presentation.http.controllers.api;

import std.uuid : randomUUID;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;
import uim.platform.service.presentation.odata.engine : ODataEngine;
import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

/// REST resource path → entity set.
enum string[string] restResources = [
    "spaces": "Spaces", "members": "Members", "connections": "Connections", "remote-tables": "RemoteTables",
    "views": "Views", "data-flows": "DataFlows", "tasks": "Tasks", "task-chains": "TaskChains", "runs": "Runs",
    "access-controls": "AccessControls", "catalog": "CatalogAssets", "users": "Users"
  ];

/// The state of one REST call.
struct ApiCall {
  RequestContext ctx;
  HTTPServerRequest req;
  Json body;
  string text; /// raw body
  int status = 200;

  string param(string name) @trusted {
    return req.params.get(name, "");
  }

  string header(string name) @trusted {
    return req.headers.get(name, "");
  }

  string query(string name, string fallback = "") @trusted {
    return req.query.get(name, fallback);
  }

  string[string] queryOptions() @trusted {
    string[string] o;
    foreach (k, v; req.query.byKeyValue)
      o[k] = v;
    return o;
  }
}

class DspApiController {
  protected ODataEngine engine;
  protected DspPorts ports;
  protected SecuritySetup security;
  protected DspPolicy policy;
  protected string root;
  protected string serviceVersion;
  protected size_t maxBody;
  protected Json capabilities;

  this(ODataEngine engine, DspPorts ports, SecuritySetup security, DspPolicy policy, string apiPath = "/api/v1",
    string serviceVersion = "2.0.0", size_t maxBody = 4 * 1024 * 1024, Json capabilities = Json.emptyObject) {
    this.engine = engine;
    this.ports = ports;
    this.security = security;
    this.policy = policy;
    this.root = "/" ~ apiPath.strip("/") ~ "/datasphere";
    this.serviceVersion = serviceVersion;
    this.maxBody = maxBody;
    this.capabilities = capabilities;
  }

  void registerRoutes(URLRouter router) {
    route(router, "GET", "/meta", (ref ApiCall c) => meta());
    route(router, "GET", "/capabilities", (ref ApiCall c) => capabilities);
    route(router, "GET", "/statistics", (ref ApiCall c) => engine.read(c.ctx, "Statistics", ""));
    route(router, "POST", "/demo-data", (ref ApiCall c) => engine.invoke(c.ctx, "SeedDemoData", Json.emptyObject));
    route(router, "POST", "/scheduler/run", (ref ApiCall c) => engine.invoke(c.ctx, "RunDueSchedules", Json.emptyObject));
    route(router, "POST", "/runs/purge", (ref ApiCall c) => engine.invoke(c.ctx, "PurgeRuns", Json.emptyObject));
    route(router, "GET", "/catalog/search", (ref ApiCall c) => searchCatalog(c));

    // spaces
    operation(router, "spaces", "lock", "LockSpace", "reason");
    operation(router, "spaces", "unlock", "UnlockSpace");
    foreach (child; ["members", "connections", "remote-tables", "views", "data-flows", "tasks", "task-chains", "runs",
        "access-controls", "catalog"])
      children(router, "spaces", child, restResources[child], "spaceId", child == "runs" ? "startedAt desc" : "createdAt");

    // integration
    operation(router, "connections", "validate", "ValidateConnection");
    children(router, "connections", "remote-tables", "RemoteTables", "connectionId", "name");
    operation(router, "remote-tables", "replicate", "ReplicateRemoteTable");
    operation(router, "remote-tables", "drop-replica", "DropReplica");

    // modeling
    operation(router, "views", "deploy", "DeployView");
    operation(router, "views", "persist", "PersistView");
    operation(router, "views", "remove-persistence", "RemovePersistence");
    route(router, "POST", "/views/:id/check-access", (ref ApiCall c) @trusted {
      auto p = Json.emptyObject;
      p["viewId"] = c.param("id");
      p["user"] = "user" in c.body && c.body["user"].type == Json.Type.string ? c.body["user"] : Json(c.ctx.actor);
      auto row = "row" in c.body ? c.body["row"] : Json.emptyObject;
      p["row"] = row.type == Json.Type.string ? row.get!string : row.toString;
      return engine.invoke(c.ctx, "CheckDataAccess", p);
    });
    operation(router, "data-flows", "deploy", "DeployDataFlow");
    operation(router, "data-flows", "run", "RunDataFlow");

    // scheduling
    operation(router, "tasks", "run", "RunTask");
    operation(router, "tasks", "pause", "PauseTask");
    operation(router, "tasks", "resume", "ResumeTask");
    children(router, "tasks", "runs", "Runs", "taskId", "startedAt desc");
    operation(router, "task-chains", "run", "RunTaskChain");
    operation(router, "task-chains", "pause", "PauseTaskChain");
    operation(router, "task-chains", "resume", "ResumeTaskChain");
    children(router, "task-chains", "runs", "Runs", "objectId", "startedAt desc");
    children(router, "runs", "steps", "Runs", "chainRunId", "startedAt");

    // CRUD of every resource
    foreach (path, set; restResources)
      resource(router, path, set);
  }

  /// Ranked catalog search: the port ranks, the engine reads (scopes, rows).
  protected Json searchCatalog(ref ApiCall c) {
    engine.query(c.ctx, "CatalogAssets", ["$top": "1"]); // scope check
    auto space = c.query("space").strip;
    auto rows = Json.emptyArray;
    foreach (a; ports.catalog.search(tenantOf(c.ctx), c.query("q"), SpaceId(space)))
      rows ~= engine.read(c.ctx, "CatalogAssets", a.id.value);
    return Json(["count": Json(rows.length), "resources": rows]);
  }

  // ── building blocks ───────────────────────────────────────────────────────

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

  /// POST /<path>/{id}/<verb> → action(id, status)
  protected void statusOperation(URLRouter router, string path, string verb, string action, string status) {
    route(router, "POST", "/" ~ path ~ "/:id/" ~ verb, (ref ApiCall c) => engine.invoke(c.ctx, action,
        Json(["id": Json(c.param("id")), "status": Json(status)])));
  }

  /// GET /<path>/{id}/<child> → the child set filtered by its reference.
  protected void children(URLRouter router, string path, string child, string set, string reference, string orderBy) {
    route(router, "GET", "/" ~ path ~ "/:id/" ~ child, (ref ApiCall c) {
      auto id = c.param("id");
      if (!isValidId(id))
        throw DspException.notFound("'" ~ id ~ "'");
      engine.read(c.ctx, restResources[path], id); // 404 for unknown parents
      auto options = c.queryOptions;
      auto filter = reference ~ " eq '" ~ id ~ "'";
      options["$filter"] = "$filter" in options ? "(" ~ options["$filter"] ~ ") and " ~ filter : filter;
      if ("$orderby" !in options)
        options["$orderby"] = orderBy;
      return page(engine.query(c.ctx, set, options));
    });
  }

  protected void requireScope(ref ApiCall c, string scope_) {
    if (engine.enforceScopes && !c.ctx.hasScope(scope_))
      throw EntitySetException.forbidden("Missing scope '" ~ scope_ ~ "'");
  }

  protected static Json page(ODataPage p) {
    return Json(["count": Json(p.total), "resources": Json(p.rows)]);
  }

  protected Json meta() {
    auto j = Json.emptyObject;
    j["service"] = "uim-datasphere";
    j["version"] = serviceVersion;
    j["security"] = security.mode;
    j["resources"] = texts(restResources.keys.sort.array);
    j["connectionTypes"] = texts(domainEnumValues!ConnectionType);
    j["replicationModes"] = texts(domainEnumValues!ReplicationMode);
    j["viewSemantics"] = texts(domainEnumValues!ViewSemantic);
    j["taskTypes"] = texts(domainEnumValues!TaskType);
    j["frequencies"] = texts(domainEnumValues!ScheduleFrequency);
    j["runStatuses"] = texts(domainEnumValues!RunStatus);
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
  protected void route(URLRouter router, string method, string path, Json delegate(ref ApiCall) @safe action,
    bool rawBody = false) {
    auto full = root ~ path;
    auto withBody = method == "POST" || method == "PUT" || method == "PATCH";
    auto handler = (HTTPServerRequest req, HTTPServerResponse res) @safe {
      serve(req, res, withBody, rawBody, action);
    };
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

  protected void serve(HTTPServerRequest req, HTTPServerResponse res, bool withBody, bool rawBody,
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
        if (withBody) {
          string text;
          try
            text = req.bodyReader.readAllUTF8(false, maxBody);
          catch (Exception e)
            throw new EntitySetException(413, "PayloadTooLarge", "The request body exceeds " ~ maxBody.to!string ~ " bytes");
          c.text = text;
          c.body = rawBody ? Json.emptyObject : parseBody(text);
        } else
          c.body = Json.emptyObject;
        body = action(c);
        status = c.status;
      }
    } catch (EntitySetException e) {
      status = e.status;
      body = errorBody(e.status.to!string, e.msg, requestId, target);
    } catch (DatasphereException e) {
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

  /// Any JSON value (object or array).
  static Json parseAny(string text) @trusted {
    try
      return parseJsonString(text);
    catch (Exception e)
      throw DspException.invalid("Request body is not valid JSON: " ~ e.msg);
  }

  static Json parseBody(string text) @trusted {
    if (text.strip.length == 0)
      return Json.emptyObject;
    auto j = parseAny(text);
    if (!j.isObject)
      throw DspException.invalid("Request body must be a JSON object");
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
