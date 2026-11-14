/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Plain REST/JSON adapter (/api/v1/task-center) over the same engine as
/// OData, so both protocols share validation, scopes and error semantics.
/// The resource paths of the 1.x API are kept.
///
///   GET    <root>/<resource>[?filter=&orderby=&select=&search=&top=&skip=]  → {items, totalCount}
///   POST   <root>/<resource>                                               → 201 entity
///   GET    <root>/<resource>/:id                                           → entity
///   PUT    <root>/<resource>/:id   (merge, also PATCH)                     → entity
///   DELETE <root>/<resource>/:id                                           → 204
///   GET    <root>/statistics
///   POST   <root>/tasks/:id/{claim|release|forward|approve|reject|complete|cancel|escalate|resubmit}
///          {"forwardTo": "…", "comment": "…"}                              → task
///   GET    <root>/tasks/:id/{comments|attachments|actions}
///   POST   <root>/providers/:id/sync          POST <root>/providers/sync (all)
///   POST   <root>/{providers|definitions|substitutions}/:id/{activate|deactivate}
///   POST   <root>/filters/:id/default
///
/// Errors: {"error": {"code": "...", "message": "..."}} with the HTTP status.
module uim.platform.task_center.presentation.http.controllers.rest;

import std.traits : EnumMembers;
import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;
import uim.platform.service.presentation.odata;
import uim.platform.task_center;

mixin(ShowModule!());

@safe:

/// REST path segment → entity set.
immutable string[2][] restResources = [
  ["tasks", "Tasks"], ["definitions", "TaskDefinitions"], ["providers", "TaskProviders"], ["comments", "TaskComments"],
  ["attachments", "TaskAttachments"], ["actions", "TaskActions"], ["substitutions", "SubstitutionRules"],
  ["filters", "UserTaskFilters"]
];

class TaskCenterRestController {
  protected ODataEngine engine;
  protected SecuritySetup security;
  protected string root;

  this(ODataEngine engine, SecuritySetup security, string root = "/api/v1/task-center") {
    this.engine = engine;
    this.security = security;
    this.root = "/" ~ root.strip("/");
  }

  void registerRoutes(URLRouter router) {
    // specific routes first so that "/:id" does not shadow them
    router.get(root ~ "/statistics", (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 200, (const RequestContext ctx) => engine.read(ctx, "Statistics", ""));
    });
    router.post(root ~ "/providers/sync", (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 200, (const RequestContext ctx) {
        auto j = Json.emptyObject;
        j["items"] = engine.invoke(ctx, "SyncAllProviders", Json.emptyObject);
        return j;
      });
    });
    router.post(root ~ "/providers/:id/sync", (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 200, (const RequestContext ctx) => engine.invoke(ctx, "SyncProvider", param("providerId", req.params["id"])));
    });
    static foreach (action; EnumMembers!ActionType)
      router.post(root ~ "/tasks/:id/" ~ cast(string) action, (HTTPServerRequest req, HTTPServerResponse res) {
        handle(req, res, 200, (const RequestContext ctx) {
          auto body = bodyOf(req);
          auto p = param("taskId", req.params["id"]);
          p["action"] = cast(string) action;
          foreach (name; ["forwardTo", "toUser"]) // toUser: 1.x name
            if (name in body && body[name].type == Json.Type.string)
              p["forwardTo"] = body[name];
          if ("comment" in body && body["comment"].type == Json.Type.string)
            p["comment"] = body["comment"];
          return engine.invoke(ctx, "PerformTaskAction", p);
        });
      });
    foreach (child; [["comments", "TaskComments"], ["attachments", "TaskAttachments"], ["actions", "TaskActions"]])
      mountChildren(router, child[0], child[1]);
    toggle(router, "providers", "TaskProviders", "activate", "status", Json("active"));
    toggle(router, "providers", "TaskProviders", "deactivate", "status", Json("inactive"));
    toggle(router, "definitions", "TaskDefinitions", "activate", "isActive", Json(true));
    toggle(router, "definitions", "TaskDefinitions", "deactivate", "isActive", Json(false));
    toggle(router, "substitutions", "SubstitutionRules", "activate", "status", Json("active"));
    toggle(router, "substitutions", "SubstitutionRules", "deactivate", "status", Json("inactive"));
    toggle(router, "filters", "UserTaskFilters", "default", "isDefault", Json(true));
    foreach (r; restResources)
      mount(router, r[0], r[1]);
  }

  protected static Json param(string name, string value) {
    auto p = Json.emptyObject;
    p[name] = value;
    return p;
  }

  /// GET <root>/tasks/:id/<segment> → the set filtered by taskId.
  protected void mountChildren(URLRouter router, string segment, string set) {
    router.get(root ~ "/tasks/:id/" ~ segment, (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 200, (const RequestContext ctx) @trusted {
        engine.read(ctx, "Tasks", req.params["id"]); // 404 for unknown tasks
        auto options = queryOptions(req);
        auto byTask = "taskId eq '" ~ req.params["id"].replace("'", "''") ~ "'";
        options["$filter"] = "$filter" in options ? "(" ~ options["$filter"] ~ ") and " ~ byTask : byTask;
        return pageBody(engine.query(ctx, set, options));
      });
    });
  }

  /// POST <root>/<segment>/:id/<verb> → PATCH {property: value}.
  protected void toggle(URLRouter router, string segment, string set, string verb, string property, Json value) {
    router.post(root ~ "/" ~ segment ~ "/:id/" ~ verb, (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 200, (const RequestContext ctx) {
        auto p = Json.emptyObject;
        p[property] = value;
        return engine.update(ctx, set, req.params["id"], p);
      });
    });
  }

  protected void mount(URLRouter router, string segment, string set) {
    auto base = root ~ "/" ~ segment;
    router.get(base, (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 200, (const RequestContext ctx) => pageBody(engine.query(ctx, set, queryOptions(req))));
    });
    router.post(base, (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 201, (const RequestContext ctx) => engine.create(ctx, set, bodyOf(req)));
    });
    router.get(base ~ "/:id", (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 200, (const RequestContext ctx) => engine.read(ctx, set, req.params["id"]));
    });
    auto update = (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 200, (const RequestContext ctx) => engine.update(ctx, set, req.params["id"], bodyOf(req)));
    };
    router.put(base ~ "/:id", update);
    router.patch(base ~ "/:id", update);
    router.delete_(base ~ "/:id", (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 204, (const RequestContext ctx) {
        engine.remove(ctx, set, req.params["id"]);
        return Json(null);
      });
    });
  }

  static Json pageBody(ODataPage page) {
    auto j = Json.emptyObject;
    j["items"] = Json(page.rows);
    j["totalCount"] = page.total;
    if (page.nextSkip > 0)
      j["nextSkip"] = page.nextSkip;
    return j;
  }

  /// filter / $filter etc. → OData system query options.
  static string[string] queryOptions(HTTPServerRequest req) @trusted {
    string[string] options;
    foreach (name; ["filter", "orderby", "select", "search", "top", "skip"]) {
      auto value = req.query.get("$" ~ name, req.query.get(name, ""));
      if (value.length > 0)
        options["$" ~ name] = value;
    }
    return options;
  }

  static Json bodyOf(HTTPServerRequest req) @trusted {
    auto text = req.bodyReader.readAllUTF8(false, 4 * 1024 * 1024);
    if (text.strip.length == 0)
      return Json.emptyObject;
    Json j;
    try
      j = parseJsonString(text);
    catch (Exception e)
      throw EntitySetException.invalid("Request body is not valid JSON: " ~ e.msg);
    if (!j.isObject)
      throw EntitySetException.invalid("Request body must be a JSON object");
    return j;
  }

  protected void handle(HTTPServerRequest req, HTTPServerResponse res, int okStatus,
    scope Json delegate(const RequestContext) @safe action) @trusted {
    int status = okStatus;
    Json body;
    try {
      auto ctx = security.resolve(req, "rest");
      if (security.requireAuthentication && !ctx.authenticated) {
        status = 401;
        body = errorBody("Unauthorized", "A valid bearer token is required");
      } else
        body = action(ctx);
    } catch (EntitySetException e) {
      status = e.status;
      body = errorBody(e.code, e.msg);
    } catch (TaskCenterException e) {
      auto t = toEntitySetException(e);
      status = t.status;
      body = errorBody(t.code, t.msg);
    } catch (ODataQueryException e) {
      status = 400;
      body = errorBody("BadRequest", "Invalid query: " ~ e.msg);
    } catch (Exception e) {
      status = 500;
      body = errorBody("InternalError", "Internal error");
      logServiceEvent("error", "unhandled REST error", Json([
            "path": Json(req.requestPath.toString), "error": Json(e.msg)
          ]));
    }
    if (status == 204) {
      res.statusCode = 204;
      res.writeVoidBody();
    } else
      res.writeJsonBody(body, status);
  }

  static Json errorBody(string code, string message) {
    auto e = Json.emptyObject;
    e["code"] = code;
    e["message"] = message;
    auto j = Json.emptyObject;
    j["error"] = e;
    return j;
  }
}
