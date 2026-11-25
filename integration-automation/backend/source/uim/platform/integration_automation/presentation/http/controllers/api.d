/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST API under <root>/integration-automation (default
/// /api/v1/integration-automation). Every call goes through the OData
/// engine, so REST, OData, CLI and GUI validate, authorize and answer alike.
///
///   GET    /<resource>[?$filter=…&$orderby=…&$top=…&$skip=…&$search=…]   → {count, resources}
///   GET    /<resource>/{id}
///   POST   /<resource>                                                  → 201
///   PUT    /<resource>/{id}      (also PATCH; partial update)
///   DELETE /<resource>/{id}                                             → 204
///
///   resources: systems, destinations, scenarios, scenario-tasks, workflows,
///   tasks (PATCH: assignedTo, priority), execution-logs (read only), users
///
///   POST   /systems/{id}/test
///   POST   /scenarios/{id}/activate | /deprecate | /archive
///   POST   /scenarios/{id}/copy                {newId?}
///   GET    /scenarios/{id}/tasks
///   POST   /workflows/{id}/start | /suspend | /resume
///   POST   /workflows/{id}/terminate           {reason?}
///   GET    /workflows/{id}/tasks | /logs
///   POST   /tasks/{id}/start | /retry
///   POST   /tasks/{id}/complete                {result?}
///   POST   /tasks/{id}/fail                    {errorMessage}
///   POST   /tasks/{id}/skip                    {reason}
///   POST   /tasks/{id}/assign                  {assignedTo?, priority?}
///   GET    /my-tasks                           open tasks assigned to the caller
///   POST   /automation/run                     {workflowId?}
///   POST   /execution-logs/purge               {olderThanDays}
///   GET    /statistics
///   GET    /meta
///   POST   /demo-data
///
/// Errors answer {"error": {code, message, requestId, target}} with
/// 400/401/403/404/405/409/422/500.
module uim.platform.integration_automation.presentation.http.controllers.api;

import std.uuid : randomUUID;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;
import uim.platform.service.presentation.odata.engine : ODataEngine;
import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

/// REST resource path → entity set.
enum string[string] restResources = [
    "systems": "Systems", "destinations": "Destinations", "scenarios": "Scenarios",
    "scenario-tasks": "ScenarioTasks", "workflows": "Workflows", "tasks": "WorkflowTasks",
    "execution-logs": "ExecutionLogs", "users": "Users"
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

class IaApiController {
  protected ODataEngine engine;
  protected SecuritySetup security;
  protected string root;
  protected string serviceVersion;
  protected size_t maxBody;

  this(ODataEngine engine, SecuritySetup security, string apiPath = "/api/v1", string serviceVersion = "2.0.0",
    size_t maxBody = 4 * 1024 * 1024) {
    this.engine = engine;
    this.security = security;
    this.root = "/" ~ apiPath.strip("/") ~ "/integration-automation";
    this.serviceVersion = serviceVersion;
    this.maxBody = maxBody;
  }

  void registerRoutes(URLRouter router) {
    route(router, "GET", "/meta", (ref ApiCall c) => meta());
    route(router, "GET", "/statistics", (ref ApiCall c) => engine.read(c.ctx, "Statistics", ""));
    route(router, "POST", "/demo-data", (ref ApiCall c) => engine.invoke(c.ctx, "SeedDemoData", Json.emptyObject));
    route(router, "POST", "/automation/run", (ref ApiCall c) => engine.invoke(c.ctx, "RunAutomatedTasks",
        pick(c.body, "workflowId")));
    route(router, "POST", "/execution-logs/purge", (ref ApiCall c) => engine.invoke(c.ctx, "PurgeExecutionLogs",
        pick(c.body, "olderThanDays")));
    route(router, "GET", "/my-tasks", (ref ApiCall c) {
      auto user = c.ctx.userId;
      auto options = c.queryOptions;
      auto mine = "assignedTo eq '" ~ user.replace("'", "''") ~ "' and (status eq 'pending' or status eq 'inProgress')";
      options["$filter"] = "$filter" in options ? "(" ~ options["$filter"] ~ ") and " ~ mine : mine;
      if ("$orderby" !in options)
        options["$orderby"] = "workflowName,sequenceNumber";
      return page(engine.query(c.ctx, "WorkflowTasks", options));
    });

    // operations on single resources
    operation(router, "systems", "test", "TestSystemConnection");
    operation(router, "scenarios", "activate", "ActivateScenario");
    operation(router, "scenarios", "deprecate", "DeprecateScenario");
    operation(router, "scenarios", "archive", "ArchiveScenario");
    operation(router, "scenarios", "copy", "CopyScenario", "newId");
    operation(router, "workflows", "start", "StartWorkflow");
    operation(router, "workflows", "suspend", "SuspendWorkflow");
    operation(router, "workflows", "resume", "ResumeWorkflow");
    operation(router, "workflows", "terminate", "TerminateWorkflow", "reason");
    operation(router, "tasks", "start", "StartTask");
    operation(router, "tasks", "complete", "CompleteTask", "result");
    operation(router, "tasks", "fail", "FailTask", "errorMessage");
    operation(router, "tasks", "skip", "SkipTask", "reason");
    operation(router, "tasks", "retry", "RetryTask");
    operation(router, "tasks", "assign", "AssignTask", "assignedTo", "priority");

    // children
    children(router, "scenarios", "tasks", "ScenarioTasks", "scenarioId", "sequenceNumber");
    children(router, "workflows", "tasks", "WorkflowTasks", "workflowId", "sequenceNumber");
    children(router, "workflows", "logs", "ExecutionLogs", "workflowId", "createdAt");

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
        throw IaException.notFound("'" ~ id ~ "'");
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
    j["service"] = "uim-integration-automation";
    j["version"] = serviceVersion;
    j["security"] = security.mode;
    j["resources"] = texts(restResources.keys.sort.array);
    j["scenarioStatuses"] = texts(domainEnumValues!ScenarioStatus);
    j["scenarioCategories"] = texts(domainEnumValues!ScenarioCategory);
    j["systemTypes"] = texts(domainEnumValues!SystemType);
    j["systemEnvironments"] = texts(domainEnumValues!SystemEnvironment);
    j["connectionStatuses"] = texts(domainEnumValues!ConnectionStatus);
    j["destinationTypes"] = texts(domainEnumValues!DestinationType);
    j["authenticationTypes"] = texts(domainEnumValues!AuthenticationType);
    j["proxyTypes"] = texts(domainEnumValues!ProxyType);
    j["taskTypes"] = texts(domainEnumValues!TaskType);
    j["taskPriorities"] = texts(domainEnumValues!TaskPriority);
    j["taskStatuses"] = texts(domainEnumValues!TaskStatus);
    j["workflowStatuses"] = texts(domainEnumValues!WorkflowStatus);
    j["executionOutcomes"] = texts(domainEnumValues!ExecutionOutcome);
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
    } catch (IntegrationAutomationException e) {
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
      throw IaException.invalid("Request body is not valid JSON: " ~ e.msg);
    if (!j.isObject)
      throw IaException.invalid("Request body must be a JSON object");
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
