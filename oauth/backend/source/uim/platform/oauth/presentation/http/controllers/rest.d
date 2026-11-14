/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Plain REST/JSON management adapter (/api/v1/oauth) over the same engine
/// as OData, so both protocols share validation, scopes and error semantics.
///
///   GET    <root>/<resource>[?filter=&orderby=&select=&search=&top=&skip=]  → {items, totalCount}
///   POST   <root>/<resource>                                               → 201 entity
///   GET    <root>/<resource>/:id                                           → entity
///   PUT    <root>/<resource>/:id   (merge, also PATCH)                     → entity
///   DELETE <root>/<resource>/:id                                           → 204
///   GET    <root>/statistics
///   POST   <root>/clients/:id/rotate-secret
///   POST   <root>/clients/:id/revoke-tokens
///   POST   <root>/access-tokens/:id/revoke
///   POST   <root>/refresh-tokens/:id/revoke
///   POST   <root>/introspect            {"token": "...", "tokenTypeHint": "..."}
///   POST   <root>/purge
///
/// Errors: {"error": {"code": "...", "message": "..."}} with the HTTP status.
module uim.platform.oauth.presentation.http.controllers.rest;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;
import uim.platform.service.presentation.odata;
import uim.platform.oauth;

mixin(ShowModule!());

@safe:

/// REST path segment → entity set.
immutable string[2][] restResources = [
  ["clients", "OAuthClients"], ["scopes", "OAuthScopes"], ["access-tokens", "AccessTokens"],
  ["refresh-tokens", "RefreshTokens"], ["authorization-codes", "AuthorizationCodes"], ["brandings", "BrandingConfigs"]
];

/// REST action route → (OData action, name of the id parameter or "").
immutable string[3][] restActions = [
  ["clients/:id/rotate-secret", "RotateClientSecret", "id"], ["clients/:id/revoke-tokens", "RevokeClientTokens", "id"],
  ["access-tokens/:id/revoke", "RevokeAccessToken", "id"], ["refresh-tokens/:id/revoke", "RevokeRefreshToken", "id"],
  ["introspect", "IntrospectToken", ""], ["purge", "PurgeExpired", ""]
];

class OAuthRestController {
  protected ODataEngine engine;
  protected SecuritySetup security;
  protected string root;

  this(ODataEngine engine, SecuritySetup security, string root = "/api/v1/oauth") {
    this.engine = engine;
    this.security = security;
    this.root = "/" ~ root.strip("/");
  }

  void registerRoutes(URLRouter router) {
    // actions first: "/clients/:id/rotate-secret" must not be shadowed
    foreach (a; restActions)
      mountAction(router, a[0], a[1], a[2]);
    router.get(root ~ "/statistics", (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 200, (const RequestContext ctx) => engine.read(ctx, "Statistics", ""));
    });
    foreach (r; restResources)
      mount(router, r[0], r[1]);
  }

  /// One route per call: closures created inside a foreach body would all
  /// share the loop variables (D issue 2043), so each gets its own frame.
  protected void mountAction(URLRouter router, string route, string action, string idParam) {
    router.post(root ~ "/" ~ route, (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 200, (const RequestContext ctx) @trusted {
        auto p = bodyOf(req);
        if (idParam.length)
          p[idParam] = req.params["id"];
        return engine.invoke(ctx, action, p);
      });
    });
  }

  protected void mount(URLRouter router, string segment, string set) {
    auto base = root ~ "/" ~ segment;
    router.get(base, (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 200, (const RequestContext ctx) {
        auto page = engine.query(ctx, set, queryOptions(req));
        auto j = Json.emptyObject;
        j["items"] = Json(page.rows);
        j["totalCount"] = page.total;
        if (page.nextSkip > 0)
          j["nextSkip"] = page.nextSkip;
        return j;
      });
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
    auto text = req.bodyReader.readAllUTF8(false, 1024 * 1024);
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
    } catch (OAuthException e) {
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
    res.headers["Cache-Control"] = "no-store"; // responses may carry secrets (create / rotate)
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
