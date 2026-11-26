/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST API under <root>/appevents (default /api/v1/appevents). Every
/// management call goes through the OData engine, so REST, OData, CLI and
/// GUI validate, authorize and answer alike.
///
///   GET    /<resource>[?$filter=…&$orderby=…&$top=…&$skip=…&$search=…]   → {count, resources}
///   GET    /<resource>/{id}
///   POST   /<resource>                                                  → 201
///   PUT    /<resource>/{id}      (also PATCH; partial update)
///   DELETE /<resource>/{id}                                             → 204
///
///   resources: formations, systems, event-types, channels, subscriptions,
///   filters, messages (read only), dead-letters (read only), users
///
///   POST   /events                      publish a CloudEvent (scope Publish) → 202 {…PublishResult}
///                                       structured: application/cloudevents+json or JSON
///                                       batch:      {"events": [ … ]} or [ … ] → 207 {count, results}
///                                       binary:     ce-type / ce-source / ce-id headers, body = data
///   POST   /events/preview              routing without delivery (scope Read)
///   POST   /formations/{id}/activate | /deactivate
///   GET    /formations/{id}/systems
///   POST   /formations/{id}/systems     {systemId}     assign a system
///   DELETE /formations/{id}/systems/{systemId}         remove a system from the formation
///   POST   /systems/{id}/activate | /deactivate
///   POST   /event-types/{id}/status     {status: active|deprecated|retired}
///   POST   /channels/{id}/activate | /deactivate | /drain
///   GET    /channels/{id}/messages
///   GET    /channels/{id}/pull?max=10   queued messages of a queue channel (scope Operate)
///   POST   /subscriptions/{id}/pause | /resume
///   GET    /subscriptions/{id}/filters | /messages | /dead-letters
///   POST   /subscriptions/{id}/dead-letters/requeue
///   POST   /messages/{id}/deliver | /ack
///   POST   /messages/purge              apply the retention periods
///   POST   /dead-letters/{id}/requeue | /discard
///   POST   /delivery/dispatch           deliver all due messages
///   GET    /statistics | /capabilities | /meta
///   POST   /demo-data
///
/// Errors answer {"error": {code, message, requestId, target}} with
/// 400/401/403/404/405/409/413/422/500.
module uim.platform.application_events.presentation.http.controllers.api;

import std.uuid : randomUUID;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;
import uim.platform.service.presentation.odata.engine : ODataEngine;
import uim.platform.application_events;

mixin(ShowModule!());

@safe:

/// REST resource path → entity set.
enum string[string] restResources = [
    "formations": "Formations", "systems": "Systems", "event-types": "EventTypes", "channels": "Channels",
    "subscriptions": "Subscriptions", "filters": "Filters", "messages": "Messages", "dead-letters": "DeadLetters",
    "users": "Users"
  ];

/// The state of one REST call.
struct ApiCall {
  RequestContext ctx;
  HTTPServerRequest req;
  Json body;
  string text; /// raw body (binary CloudEvents)
  int status = 200;

  string param(string name) @trusted {
    return req.params.get(name, "");
  }

  string header(string name) @trusted {
    return req.headers.get(name, "");
  }

  string[string] queryOptions() @trusted {
    string[string] o;
    foreach (k, v; req.query.byKeyValue)
      o[k] = v;
    return o;
  }
}

class AehApiController {
  protected ODataEngine engine;
  protected AehPorts ports;
  protected SecuritySetup security;
  protected AehPolicy policy;
  protected string root;
  protected string serviceVersion;
  protected size_t maxBody;
  protected Json capabilities;

  this(ODataEngine engine, AehPorts ports, SecuritySetup security, AehPolicy policy, string apiPath = "/api/v1",
    string serviceVersion = "2.0.0", size_t maxBody = 4 * 1024 * 1024, Json capabilities = Json.emptyObject) {
    this.engine = engine;
    this.ports = ports;
    this.security = security;
    this.policy = policy;
    this.root = "/" ~ apiPath.strip("/") ~ "/appevents";
    this.serviceVersion = serviceVersion;
    this.maxBody = maxBody;
    this.capabilities = capabilities;
  }

  void registerRoutes(URLRouter router) {
    route(router, "GET", "/meta", (ref ApiCall c) => meta());
    route(router, "GET", "/capabilities", (ref ApiCall c) => capabilities);
    route(router, "GET", "/statistics", (ref ApiCall c) => engine.read(c.ctx, "Statistics", ""));
    route(router, "POST", "/demo-data", (ref ApiCall c) => engine.invoke(c.ctx, "SeedDemoData", Json.emptyObject));
    route(router, "POST", "/delivery/dispatch", (ref ApiCall c) => engine.invoke(c.ctx, "DispatchDue", Json.emptyObject));
    route(router, "POST", "/messages/purge", (ref ApiCall c) => engine.invoke(c.ctx, "PurgeMessages", Json.emptyObject));

    // publishing
    route(router, "POST", "/events", (ref ApiCall c) => publishEvents(c, false), true);
    route(router, "POST", "/events/preview", (ref ApiCall c) => publishEvents(c, true), true);

    // landscape
    statusOperation(router, "formations", "activate", "SetFormationStatus", "active");
    statusOperation(router, "formations", "deactivate", "SetFormationStatus", "inactive");
    children(router, "formations", "systems", "Systems", "formationId", "name");
    route(router, "POST", "/formations/:id/systems", (ref ApiCall c) {
      auto p = pick(c.body, "systemId");
      p["id"] = c.param("id");
      return engine.invoke(c.ctx, "AssignSystem", p);
    });
    route(router, "DELETE", "/formations/:id/systems/:system", (ref ApiCall c) {
      auto s = engine.read(c.ctx, "Systems", c.param("system"));
      if (textOf(s, "formationId") != c.param("id"))
        throw AehException.notFound("System '" ~ c.param("system") ~ "' in formation '" ~ c.param("id") ~ "'");
      return engine.invoke(c.ctx, "UnassignSystem", Json(["systemId": Json(c.param("system"))]));
    });
    statusOperation(router, "systems", "activate", "SetSystemStatus", "active");
    statusOperation(router, "systems", "deactivate", "SetSystemStatus", "inactive");
    children(router, "systems", "channels", "Channels", "consumerSystemId", "name");

    // catalog and channels
    operation(router, "event-types", "status", "SetEventTypeStatus", "status");
    statusOperation(router, "channels", "activate", "SetChannelStatus", "active");
    statusOperation(router, "channels", "deactivate", "SetChannelStatus", "inactive");
    statusOperation(router, "channels", "drain", "SetChannelStatus", "draining");
    children(router, "channels", "messages", "Messages", "channelId", "createdAt desc");
    route(router, "GET", "/channels/:id/pull", (ref ApiCall c) @trusted {
      requireScope(c, operateScope);
      auto max = cast(size_t) longOf(Json(["max": Json(c.req.query.get("max", "10"))]), "max", 10);
      auto t = tenantOf(c.ctx);
      auto rows = Json.emptyArray;
      foreach (m; ports.delivery.pull(t, EventChannelId(c.param("id")), max, actorOf(c.ctx)))
        rows ~= engine.read(c.ctx, "Messages", m.id.value);
      return Json(["count": Json(rows.length), "resources": rows]);
    });

    // subscriptions
    operation(router, "subscriptions", "pause", "PauseSubscription");
    operation(router, "subscriptions", "resume", "ResumeSubscription");
    children(router, "subscriptions", "filters", "Filters", "subscriptionId", "createdAt");
    children(router, "subscriptions", "messages", "Messages", "subscriptionId", "createdAt desc");
    children(router, "subscriptions", "dead-letters", "DeadLetters", "subscriptionId", "createdAt desc");
    route(router, "POST", "/subscriptions/:id/dead-letters/requeue", (ref ApiCall c) {
      engine.read(c.ctx, "Subscriptions", c.param("id"));
      return engine.invoke(c.ctx, "RequeueDeadLetters", Json(["subscriptionId": Json(c.param("id"))]));
    });

    // messages and dead letters
    operation(router, "messages", "deliver", "DeliverMessage");
    operation(router, "messages", "ack", "AcknowledgeMessage");
    operation(router, "dead-letters", "requeue", "RequeueDeadLetter");
    operation(router, "dead-letters", "discard", "DiscardDeadLetter");

    // CRUD of every resource
    foreach (path, set; restResources)
      resource(router, path, set);
  }

  // ── publishing ────────────────────────────────────────────────────────────

  /// Structured, batch or binary CloudEvents.
  protected Json publishEvents(ref ApiCall c, bool previewOnly) @trusted {
    requireScope(c, previewOnly ? readScope : publishScope);
    Json[] events;
    bool batched;
    if (c.header("ce-type").length || c.header("ce-source").length) {
      auto e = Json.emptyObject;
      foreach (k; ["specversion", "id", "type", "source", "subject", "time"])
        if (c.header("ce-" ~ k).length)
          e[k] = c.header("ce-" ~ k);
      auto contentType = c.header("Content-Type");
      if (contentType.length)
        e["datacontenttype"] = contentType.split(";")[0].strip;
      if (c.text.strip.length) {
        try
          e["data"] = parseJsonString(c.text);
        catch (Exception)
          e["data"] = c.text;
      }
      events = [e];
    } else {
      auto body = c.text.strip.length ? parseAny(c.text) : Json.emptyObject;
      if (body.type == Json.Type.array) {
        events = body.get!(Json[]);
        batched = true;
      } else if (body.isObject && "events" in body && body["events"].type == Json.Type.array) {
        events = body["events"].get!(Json[]);
        batched = true;
      } else
        events = [body];
    }
    if (events.length == 0 || events.length > policy.maxBatchEvents)
      throw AehException.invalid(format("Send 1 to %d events", policy.maxBatchEvents));

    PublishResult run(Json e) {
      auto r = PublishRequest(tenantOf(c.ctx), actorOf(c.ctx), e);
      return previewOnly ? ports.publishing.preview(r) : ports.publishing.publish(r);
    }

    if (!batched) {
      c.status = previewOnly ? 200 : 202;
      return publishDetailRow(run(events[0]));
    }
    // batch: every event is answered on its own (207 multi-status)
    auto results = Json.emptyArray;
    foreach (e; events) {
      try {
        auto r = publishDetailRow(run(e));
        r["status"] = previewOnly ? 200 : 202;
        results ~= r;
      } catch (EventHubException ex) {
        auto x = toEntitySetException(ex);
        results ~= Json(["status": Json(x.status), "error": Json(["code": Json(x.code), "message": Json(ex.msg)]),
            "eventId": Json(e.isObject && "id" in e && e["id"].type == Json.Type.string ? e["id"].get!string : "")]);
      }
    }
    c.status = 207;
    return Json(["count": Json(results.length), "results": results]);
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
        throw AehException.notFound("'" ~ id ~ "'");
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
    j["service"] = "uim-application-events";
    j["version"] = serviceVersion;
    j["security"] = security.mode;
    j["cloudEvents"] = cloudEventsSpecVersion;
    j["resources"] = texts(restResources.keys.sort.array);
    j["systemTypes"] = texts(domainEnumValues!SystemType);
    j["channelTypes"] = texts(domainEnumValues!ChannelType);
    j["deliveryModes"] = texts(domainEnumValues!DeliveryMode);
    j["filterOperators"] = texts(domainEnumValues!EventFilterOperator);
    j["messageStatuses"] = texts(domainEnumValues!MessageStatus);
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
    } catch (EventHubException e) {
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
      throw AehException.invalid("Request body is not valid JSON: " ~ e.msg);
  }

  static Json parseBody(string text) @trusted {
    if (text.strip.length == 0)
      return Json.emptyObject;
    auto j = parseAny(text);
    if (!j.isObject)
      throw AehException.invalid("Request body must be a JSON object");
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
