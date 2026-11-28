/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST API under <root>/ai-launchpad (default /api/v1/ai-launchpad). Every
/// management call goes through the OData engine, so REST, OData, CLI and
/// GUI validate, authorize and answer alike.
///
///   GET    /<resource>[?$filter=…&$orderby=…&$top=…&$skip=…&$search=…]   → {count, resources}
///   GET    /<resource>/{id}
///   POST   /<resource>                                                  → 201
///   PUT    /<resource>/{id}      (also PATCH; partial update)
///   DELETE /<resource>/{id}                                             → 204
///
///   resources: workspaces, connections, resource-groups, scenarios,
///   configurations, executions, deployments, models, datasets,
///   prompt-collections, prompts, tiles, users, roles, logs (read only)
///
///   GET    /launchpad                   the tiles of the caller with KPI values
///   POST   /connections/{id}/validate
///   POST   /executions/{id}/stop
///   POST   /deployments/{id}/stop | /start
///   POST   /prompts/{id}/run {inputs: {name: value}}
///   GET    /workspaces/{id}/connections | prompt-collections
///   GET    /connections/{id}/resource-groups | scenarios
///   GET    /scenarios/{id}/configurations | executions | deployments | models | datasets
///   GET    /configurations/{id}/executions | deployments
///   GET    /prompt-collections/{id}/prompts
///   POST   /reconcile                   synchronize with the runtimes
///   POST   /logs/purge                  apply the audit log retention
///   POST   /tiles/restore-defaults
///   GET    /statistics | /capabilities | /meta
///   POST   /demo-data
///
/// Errors answer {"error": {code, message, requestId, target}} with
/// 400/401/403/404/405/409/413/422/500.
module uim.platform.ai_launchpad.presentation.http.controllers.api;

import std.uuid : randomUUID;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;
import uim.platform.service.presentation.odata.engine : ODataEngine;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

/// REST resource path → entity set.
enum string[string] restResources = [
    "workspaces": "Workspaces", "connections": "Connections", "resource-groups": "ResourceGroups",
    "scenarios": "Scenarios", "configurations": "Configurations", "executions": "Executions",
    "deployments": "Deployments", "models": "Models", "datasets": "Datasets", "prompt-collections": "PromptCollections",
    "prompts": "Prompts", "tiles": "Tiles", "users": "Users", "roles": "Roles", "logs": "LogEntries"
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

class AilpApiController {
  protected ODataEngine engine;
  protected AilpPorts ports;
  protected SecuritySetup security;
  protected string root;
  protected string serviceVersion;
  protected size_t maxBody;
  protected Json capabilities;

  this(ODataEngine engine, AilpPorts ports, SecuritySetup security, string apiPath = "/api/v1",
    string serviceVersion = "2.0.0", size_t maxBody = 4 * 1024 * 1024, Json capabilities = Json.emptyObject) {
    this.engine = engine;
    this.ports = ports;
    this.security = security;
    this.root = "/" ~ apiPath.strip("/") ~ "/ai-launchpad";
    this.serviceVersion = serviceVersion;
    this.maxBody = maxBody;
    this.capabilities = capabilities;
  }

  void registerRoutes(URLRouter router) {
    route(router, "GET", "/meta", (ref ApiCall c) => meta());
    route(router, "GET", "/capabilities", (ref ApiCall c) => capabilities);
    route(router, "GET", "/statistics", (ref ApiCall c) => engine.read(c.ctx, "Statistics", ""));
    route(router, "GET", "/launchpad", (ref ApiCall c) {
      auto options = c.queryOptions;
      if ("$orderby" !in options)
        options["$orderby"] = "sortOrder";
      return page(engine.query(c.ctx, "LaunchpadTiles", options));
    });
    route(router, "POST", "/demo-data", (ref ApiCall c) => engine.invoke(c.ctx, "SeedDemoData", Json.emptyObject));
    route(router, "POST", "/reconcile", (ref ApiCall c) => engine.invoke(c.ctx, "Reconcile", Json.emptyObject));
    route(router, "POST", "/logs/purge", (ref ApiCall c) => engine.invoke(c.ctx, "PurgeLogs", Json.emptyObject));
    route(router, "POST", "/tiles/restore-defaults", (ref ApiCall c) => engine.invoke(c.ctx, "RestoreDefaultTiles",
        Json.emptyObject));

    // runtimes
    operation(router, "connections", "validate", "ValidateConnection");
    children(router, "workspaces", "connections", "Connections", "workspaceId", "name");
    children(router, "workspaces", "prompt-collections", "PromptCollections", "workspaceId", "name");
    children(router, "connections", "resource-groups", "ResourceGroups", "connectionId", "id");
    children(router, "connections", "scenarios", "Scenarios", "connectionId", "name");

    // ML life cycle
    operation(router, "executions", "stop", "StopExecution");
    operation(router, "deployments", "stop", "StopDeployment");
    operation(router, "deployments", "start", "StartDeployment");
    foreach (child; ["configurations", "executions", "deployments", "models", "datasets"])
      children(router, "scenarios", child, restResources[child], "scenarioId",
        child == "executions" || child == "deployments" ? "createdAt desc" : "name");
    children(router, "configurations", "executions", "Executions", "configurationId", "createdAt desc");
    children(router, "configurations", "deployments", "Deployments", "configurationId", "createdAt desc");

    // generative AI hub
    children(router, "prompt-collections", "prompts", "Prompts", "collectionId", "name");
    route(router, "POST", "/prompts/:id/run", (ref ApiCall c) @trusted {
      auto p = Json.emptyObject;
      p["id"] = c.param("id");
      if ("inputs" in c.body)
        p["inputs"] = c.body["inputs"].type == Json.Type.string ? c.body["inputs"] : Json(c.body["inputs"].toString);
      return engine.invoke(c.ctx, "RunPrompt", p);
    });

    // CRUD of every resource
    foreach (path, set; restResources)
      resource(router, path, set);
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
        throw AilpException.notFound("'" ~ id ~ "'");
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
    j["service"] = "uim-ai-launchpad";
    j["version"] = serviceVersion;
    j["security"] = security.mode;
    j["resources"] = texts(restResources.keys.sort.array);
    j["connectionTypes"] = texts(domainEnumValues!ConnectionType);
    j["executionStatuses"] = texts(domainEnumValues!ExecutionStatus);
    j["deploymentStatuses"] = texts(domainEnumValues!DeploymentStatus);
    j["promptStatuses"] = texts(domainEnumValues!PromptStatus);
    j["logCategories"] = texts(domainEnumValues!LogCategory);
    j["kpis"] = texts(statisticNames);
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
    } catch (AiLaunchpadException e) {
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
      throw AilpException.invalid("Request body is not valid JSON: " ~ e.msg);
  }

  static Json parseBody(string text) @trusted {
    if (text.strip.length == 0)
      return Json.emptyObject;
    auto j = parseAny(text);
    if (!j.isObject)
      throw AilpException.invalid("Request body must be a JSON object");
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
