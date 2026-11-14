/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// JSON API (/api/v1) over the same engine as OData, so both protocols share
/// validation, scopes and error semantics. Paths of the previous release are
/// kept; the request bodies of the previous release are accepted as well
/// (conditions as [{attribute, op|operator, value}], isBasePolicy, attributes
/// as object).
///
///   GET    <root>/<resource>[?filter=&orderby=&select=&search=&top=&skip=]  → {items, totalCount}
///   POST   <root>/<resource>                                               → 201 entity
///   GET    <root>/<resource>/:id                                           → entity
///   PUT    <root>/<resource>/:id   (merge, also PATCH)                     → entity
///   DELETE <root>/<resource>/:id                                           → 204
///     resources: applications, application-apis, policies, policy-assignments, decisions (read only)
///   GET    <root>/policies/base
///   POST   <root>/policies/seed-base           {applicationId | applicationName [, organizationId]}
///   POST   <root>/policies/:id/enable | /disable
///   POST   <root>/authorization/evaluate       {principalId, applicationId, resource, action, attributes, groups}
///   GET    <root>/principals/:type/:id/policies[?application=]
///   GET    <root>/statistics
///
/// Errors: {"error": {"code": "...", "message": "..."}} with the HTTP status.
module uim.platform.authorization.presentation.http.controllers.api;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.stream.operations : readAllUTF8;
import uim.platform.service.presentation.odata;
import uim.platform.authorization;

mixin(ShowModule!());

@safe:

/// JSON API path segment → entity set.
immutable string[2][] apiResources = [
  ["applications", "Applications"], ["application-apis", "ApplicationApis"], ["policies", "Policies"],
  ["policy-assignments", "Assignments"], ["decisions", "Decisions"]
];

class AuthorizationApiController {
  protected ODataEngine engine;
  protected AuthorizationPorts ports;
  protected SecuritySetup security;
  protected string root;

  this(ODataEngine engine, AuthorizationPorts ports, SecuritySetup security, string root = "/api/v1") {
    this.engine = engine;
    this.ports = ports;
    this.security = security;
    this.root = "/" ~ root.strip("/");
  }

  void registerRoutes(URLRouter router) {
    // specific routes first (they would otherwise match <resource>/:id)
    router.get(root ~ "/statistics", (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 200, (const RequestContext ctx) => engine.read(ctx, "Statistics", ""));
    });
    router.get(root ~ "/policies/base", (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 200, (const RequestContext ctx) {
        auto options = queryOptions(req);
        options["$filter"] = "kind eq 'base'" ~ ("$filter" in options ? " and (" ~ options["$filter"] ~ ")" : "");
        return page(engine.query(ctx, "Policies", options));
      });
    });
    router.post(root ~ "/policies/seed-base", (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 201, (const RequestContext ctx) => seedBase(ctx, bodyOf(req)));
    });
    foreach (name; ["enable", "disable"]) {
      auto action = name == "enable" ? "EnablePolicy" : "DisablePolicy";
      router.post(root ~ "/policies/:id/" ~ name, (HTTPServerRequest req, HTTPServerResponse res) {
        handle(req, res, 200, (const RequestContext ctx) {
          auto p = Json.emptyObject;
          p["id"] = req.params["id"];
          return engine.invoke(ctx, action, p);
        });
      });
    }
    router.post(root ~ "/authorization/evaluate", (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 200, (const RequestContext ctx) => engine.invoke(ctx, "EvaluateAuthorization",
        evaluationParameters(bodyOf(req))));
    });
    router.get(root ~ "/principals/:type/:id/policies", (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 200, (const RequestContext ctx) => effective(ctx, req));
    });

    foreach (r; apiResources)
      mount(router, r[0], r[1]);
  }

  protected void mount(URLRouter router, string segment, string set) {
    auto base = root ~ "/" ~ segment;
    router.get(base, (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 200, (const RequestContext ctx) => page(engine.query(ctx, set, queryOptions(req))));
    });
    router.post(base, (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 201, (const RequestContext ctx) => engine.create(ctx, set, legacyBody(set, bodyOf(req))));
    });
    router.get(base ~ "/:id", (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 200, (const RequestContext ctx) => engine.read(ctx, set, req.params["id"]));
    });
    auto update = (HTTPServerRequest req, HTTPServerResponse res) {
      handle(req, res, 200, (const RequestContext ctx) => engine.update(ctx, set, req.params["id"],
        legacyBody(set, bodyOf(req))));
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

  // ── special endpoints ───────────────────────────────────────────────────

  /// Seed the base policies of an application; creates the application if
  /// only a (new) name is given — behaviour of the previous release.
  protected Json seedBase(const RequestContext ctx, Json p) {
    auto application = textOf(p, "applicationId");
    if (application.length == 0) {
      auto name = textOf(p, "applicationName");
      if (name.length == 0)
        name = "authorization-management";
      if (!ports.applications.listApplications(tenantOf(ctx)).any!(a => a.name == name)) {
        auto create = Json.emptyObject;
        create["name"] = name;
        create["organizationId"] = textOf(p, "organizationId").length ? textOf(p, "organizationId") : "global";
        create["description"] = "Auto-created during base policy seeding";
        engine.create(ctx, "Applications", create);
      }
      application = name;
    }
    auto params = Json.emptyObject;
    params["application"] = application;
    auto result = engine.invoke(ctx, "SeedBasePolicies", params);
    auto options = ["$filter": "kind eq 'base' and applicationId eq '" ~ result["id"].get!string ~ "'"];
    auto j = page(engine.query(ctx, "Policies", options));
    j["applicationId"] = result["id"];
    return j;
  }

  protected Json effective(const RequestContext ctx, HTTPServerRequest req) @trusted {
    auto type = parseDomainEnum!PrincipalType(req.params["type"], "principal type");
    auto principal = req.params["id"];
    auto t = tenantOf(ctx);
    string[] groups = type == PrincipalType.group ? [principal] : splitList(req.query.get("groups", ""));
    auto userId = type == PrincipalType.user ? principal : "";
    ManagedApplicationId appId;
    auto application = req.query.get("application", "");
    if (application.length)
      appId = ports.applications.resolveApplication(t, application).id;
    auto rows = Json.emptyArray;
    foreach (p; ports.evaluation.effectivePolicies(t, userId, groups, appId))
      rows ~= engine.read(ctx, "Policies", p.id.value);
    auto j = Json.emptyObject;
    j["principalType"] = cast(string) type;
    j["principalId"] = principal;
    j["items"] = rows;
    j["totalCount"] = rows.length;
    return j;
  }

  // ── payload conversion ──────────────────────────────────────────────────

  /// Accept the request bodies of the previous release.
  static Json legacyBody(string set, Json p) @trusted {
    if (set != "Policies")
      return p;
    if ("conditions" in p && p["conditions"].type == Json.Type.array) {
      string[] parts;
      foreach (c; p["conditions"]) {
        auto op = textOf(c, "operator").length ? textOf(c, "operator") : textOf(c, "op");
        parts ~= PolicyCondition(textOf(c, "attribute"), parseOperator(op.length ? op : "eq"), textOf(c, "value")).toText;
      }
      p["conditions"] = parts.join("; ");
    }
    if ("isBasePolicy" in p) {
      if ("kind" !in p)
        p["kind"] = boolOf(p, "isBasePolicy") ? "base" : "custom";
      p.remove("isBasePolicy");
    }
    return p;
  }

  /// {attributes: {k: v}, groups: [..], applicationId} → action parameters.
  static Json evaluationParameters(Json p) @trusted {
    auto params = Json.emptyObject;
    params["principalId"] = textOf(p, "principalId");
    params["application"] = textOf(p, "application").length ? textOf(p, "application") : textOf(p, "applicationId");
    params["resource"] = textOf(p, "resource");
    params["action"] = textOf(p, "action");
    if ("groups" in p)
      params["groups"] = p["groups"].type == Json.Type.array ? textsOf(p, "groups").join(", ") : textOf(p, "groups");
    if ("attributes" in p) {
      if (p["attributes"].isObject) {
        string[string] attrs;
        foreach (k, v; p["attributes"].get!(Json[string]))
          attrs[k] = v.type == Json.Type.string ? v.get!string : v.toString;
        params["attributes"] = attributesText(attrs);
      } else
        params["attributes"] = textOf(p, "attributes");
    }
    if ("record" in p)
      params["record"] = boolOf(p, "record", true);
    return params;
  }

  static Json page(ODataPage page) {
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
    } catch (AuthorizationException e) {
      auto t = toEntitySetException(e);
      status = t.status;
      body = errorBody(t.code, t.msg);
    } catch (ODataQueryException e) {
      status = 400;
      body = errorBody("BadRequest", "Invalid query: " ~ e.msg);
    } catch (Exception e) {
      status = 500;
      body = errorBody("InternalError", "Internal error");
      logAuthorizationEvent("error", "unhandled API error", Json([
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

///
unittest {
  mixin(ShowTest!("AuthorizationApiController payloads"));

  auto legacy = parseJsonString(`{"name":"p","conditions":[{"attribute":"country","op":"==","value":"US"}],"isBasePolicy":false}`);
  auto converted = AuthorizationApiController.legacyBody("Policies", legacy);
  assert(converted["conditions"].get!string == "country eq US");
  assert(converted["kind"].get!string == "custom" && "isBasePolicy" !in converted);

  auto params = AuthorizationApiController.evaluationParameters(parseJsonString(
      `{"principalId":"alice","applicationId":"a1","resource":"Incident","action":"Read","attributes":{"country":"US","level":3},"groups":["Support"]}`));
  assert(params["application"].get!string == "a1");
  assert(params["attributes"].get!string == "country=US, level=3");
  assert(params["groups"].get!string == "Support");
}
