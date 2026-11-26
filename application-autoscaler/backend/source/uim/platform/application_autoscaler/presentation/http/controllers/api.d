/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST API under <root>/autoscaler (default /api/v1/autoscaler). Every
/// call goes through the OData engine, so REST, OData, CLI and GUI
/// validate, authorize and answer alike.
///
///   GET    /<resource>[?$filter=…&$orderby=…&$top=…&$skip=…&$search=…]   → {count, resources}
///   GET    /<resource>/{id}
///   POST   /<resource>                                                  → 201
///   PUT    /<resource>/{id}      (also PATCH; partial update)
///   DELETE /<resource>/{id}                                             → 204
///
///   resources: bindings, policies, rules, schedules, metric-samples,
///   scaling-events (read only), users
///
///   POST   /bindings/{id}/evaluate              evaluate the policy now
///   GET    /bindings/{id}/preview               what the engine would decide
///   POST   /bindings/{id}/scale                 {instances, reason?}
///   POST   /bindings/{id}/suspend | /resume
///   POST   /bindings/{id}/policy                {policyId}   attach
///   DELETE /bindings/{id}/policy                             detach
///   GET    /bindings/{id}/metrics | /history
///   POST   /bindings/{id}/metrics               {metricName, value, unit?, measuredAt?}
///   POST   /bindings/{id}/simulate              {metricName, value, durationSeconds?, stepSeconds?}
///   POST   /apps/{appGuid}/metrics              {metricName, value, …} or {metrics: [{…}]}  (sent by the application)
///   POST   /policies/{id}/activate | /deactivate
///   POST   /policies/{id}/copy                  {newId?}
///   GET    /policies/{id}/rules | /schedules
///   POST   /scaling/evaluate                    evaluate every autoscaled binding
///   POST   /metrics/purge                       apply the retention periods
///   GET    /statistics | /capabilities | /meta
///   POST   /demo-data
///
/// Errors answer {"error": {code, message, requestId, target}} with
/// 400/401/403/404/405/409/422/500.
module uim.platform.application_autoscaler.presentation.http.controllers.api;

import std.uuid : randomUUID;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;
import uim.platform.service.presentation.odata.engine : ODataEngine;
import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

/// REST resource path → entity set.
enum string[string] restResources = [
    "bindings": "Bindings", "policies": "Policies", "rules": "Rules", "schedules": "Schedules",
    "metric-samples": "MetricSamples", "scaling-events": "ScalingEvents", "users": "Users"
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

class AasApiController {
  protected ODataEngine engine;
  protected AasPorts ports;
  protected SecuritySetup security;
  protected string root;
  protected string serviceVersion;
  protected size_t maxBody;
  protected Json capabilities;

  this(ODataEngine engine, AasPorts ports, SecuritySetup security, string apiPath = "/api/v1", string serviceVersion = "2.0.0",
    size_t maxBody = 1024 * 1024, Json capabilities = Json.emptyObject) {
    this.engine = engine;
    this.ports = ports;
    this.security = security;
    this.root = "/" ~ apiPath.strip("/") ~ "/autoscaler";
    this.serviceVersion = serviceVersion;
    this.maxBody = maxBody;
    this.capabilities = capabilities;
  }

  void registerRoutes(URLRouter router) {
    route(router, "GET", "/meta", (ref ApiCall c) => meta());
    route(router, "GET", "/capabilities", (ref ApiCall c) => capabilities);
    route(router, "GET", "/statistics", (ref ApiCall c) => engine.read(c.ctx, "Statistics", ""));
    route(router, "POST", "/demo-data", (ref ApiCall c) => engine.invoke(c.ctx, "SeedDemoData", Json.emptyObject));
    route(router, "POST", "/scaling/evaluate", (ref ApiCall c) => engine.invoke(c.ctx, "EvaluateAll", Json.emptyObject));
    route(router, "POST", "/metrics/purge", (ref ApiCall c) => engine.invoke(c.ctx, "PurgeMetrics", Json.emptyObject));

    // bindings
    operation(router, "bindings", "evaluate", "EvaluateBinding");
    operation(router, "bindings", "scale", "ScaleBinding", "instances", "reason");
    operation(router, "bindings", "suspend", "SuspendBinding");
    operation(router, "bindings", "resume", "ResumeBinding");
    operation(router, "bindings", "policy", "AttachPolicy", "policyId");
    route(router, "DELETE", "/bindings/:id/policy", (ref ApiCall c) => engine.invoke(c.ctx, "DetachPolicy",
        Json(["id": Json(c.param("id"))])));
    route(router, "GET", "/bindings/:id/preview", (ref ApiCall c) => engine.invoke(c.ctx, "PreviewScaling",
        Json(["id": Json(c.param("id"))])));
    route(router, "POST", "/bindings/:id/simulate", (ref ApiCall c) {
      auto p = pick(c.body, "metricName", "value", "durationSeconds", "stepSeconds");
      p["bindingId"] = c.param("id");
      return engine.invoke(c.ctx, "SimulateLoad", p);
    });
    route(router, "POST", "/bindings/:id/metrics", (ref ApiCall c) {
      auto p = pick(c.body, "metricName", "value", "unit", "measuredAt", "source");
      p["bindingId"] = c.param("id");
      c.status = 201;
      return engine.create(c.ctx, "MetricSamples", p);
    });
    route(router, "POST", "/apps/:guid/metrics", (ref ApiCall c) => appMetrics(c));
    children(router, "bindings", "metrics", "MetricSamples", "bindingId", "measuredAt desc");
    children(router, "bindings", "history", "ScalingEvents", "bindingId", "createdAt desc");

    // policies
    operation(router, "policies", "activate", "ActivatePolicy");
    operation(router, "policies", "deactivate", "DeactivatePolicy");
    operation(router, "policies", "copy", "CopyPolicy", "newId");
    children(router, "policies", "rules", "Rules", "policyId", "createdAt");
    children(router, "policies", "schedules", "Schedules", "policyId", "createdAt");

    // CRUD of every resource
    foreach (path, set; restResources)
      resource(router, path, set);
  }

  /// SAP style custom metric submission by the bound application:
  /// {metricName, value, unit?} or {metrics: [{metricName|name, value, unit?}, …]}.
  protected Json appMetrics(ref ApiCall c) @trusted {
    if (engine.enforceScopes && !c.ctx.hasScope(operateScope))
      throw EntitySetException.forbidden("Missing scope '" ~ operateScope ~ "'");
    Json[] items;
    if ("metrics" in c.body && c.body["metrics"].type == Json.Type.array)
      items = c.body["metrics"].get!(Json[]);
    else
      items = [c.body];
    if (items.length == 0 || items.length > 100)
      throw AasException.invalid("Send 1 to 100 metrics");
    auto sender = textOf(c.body, "senderAppGuid");
    auto result = Json.emptyArray;
    foreach (item; items) {
      if (!item.isObject)
        throw AasException.invalid("Every metric must be a JSON object");
      SubmitMetricRequest r;
      r.tenantId = tenantOf(c.ctx);
      r.actor = actorOf(c.ctx);
      r.appGuid = c.param("guid");
      r.metricName = textOf(item, "metricName").length ? textOf(item, "metricName") : textOf(item, "name");
      if (!("value" in item) || (item["value"].type != Json.Type.int_ && item["value"].type != Json.Type.float_))
        throw AasException.invalid("Every metric needs a numeric value");
      r.value = doubleOf(item, "value");
      r.unit = textOf(item, "unit");
      r.measuredAt = textOf(item, "measuredAt");
      r.source = "app";
      r.senderAppGuid = sender;
      auto m = ports.metrics.submit(r);
      result ~= sampleRow(m, "");
    }
    c.status = 201;
    return Json(["count": Json(result.length), "resources": result]);
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
        throw AasException.notFound("'" ~ id ~ "'");
      engine.read(c.ctx, restResources[path], id); // 404 for unknown parents
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
    j["service"] = "uim-application-autoscaler";
    j["version"] = serviceVersion;
    j["security"] = security.mode;
    j["resources"] = texts(restResources.keys.sort.array);
    j["metricTypes"] = texts(domainEnumValues!MetricType);
    j["operators"] = texts(domainEnumValues!ComparisonOperator);
    j["scheduleKinds"] = texts(domainEnumValues!ScheduleKind);
    j["policyStatuses"] = texts(domainEnumValues!PolicyStatus);
    j["bindingStatuses"] = texts(domainEnumValues!BindingStatus);
    j["triggers"] = texts(domainEnumValues!ScalingTrigger);
    j["directions"] = texts(domainEnumValues!ScalingDirection);
    j["statuses"] = texts(domainEnumValues!ScalingStatus);
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
    } catch (AutoscalerException e) {
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
      throw AasException.invalid("Request body is not valid JSON: " ~ e.msg);
    if (!j.isObject)
      throw AasException.invalid("Request body must be a JSON object");
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
