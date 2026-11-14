/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST driving adapter (JSON over HTTP) for every resource of the registry.
///
///   GET    /api/v1/<resource>[?<field>=<value>…]     → { "items": [...], "count": n }
///   POST   /api/v1/<resource>                        → 201 created resource
///   GET    /api/v1/<resource>/<id>
///   PATCH  /api/v1/<resource>/<id>   (PUT accepted)  partial update
///   DELETE /api/v1/<resource>/<id>                   → 204
///   POST   /api/v1/<resource>/<id>/<action>          e.g. /transports/<id>/release-task {"task": "..."}
///   GET    /api/v1/statistics · POST /api/v1/reconcile · GET /api/v1/resources
///
/// Errors: { "error": { "code": "...", "message": "..." } } with 400/404/409/422/500.
/// Tenant / user come from the XSUAA token or the X-Tenant-Id / X-User-Id headers.
/// System references (systemInstanceId, sourceSystemId, targetSystemId) accept an id or a name.
module uim.platform.abap_environment.presentation.http.controllers.resources;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.abap_environment;
import uim.platform.abap_environment.presentation.resources;

mixin(ShowModule!());

@safe:

class AbapRestController {
  protected ResourceRegistry registry;
  protected string defaultTenant;
  protected string prefix;

  this(ResourceRegistry registry, string defaultTenant, string prefix = "/api/v1") {
    this.registry = registry;
    this.defaultTenant = defaultTenant;
    this.prefix = prefix;
  }

  void registerRoutes(URLRouter router) {
    router.get(prefix ~ "/resources", &handleCatalog);
    router.get(prefix ~ "/statistics", (req, res) => guard(res, () {
      writeJson(res, 200, registry.statistics(identityOf(req).tenantId));
    }));
    router.post(prefix ~ "/reconcile", (req, res) => guard(res, () {
      writeJson(res, 200, registry.reconcile(identityOf(req).tenantId));
    }));
    foreach (adapter; registry.adapters)
      registerResource(router, adapter);
  }

  /// One function call per adapter, so each closure captures its own adapter.
  protected void registerResource(URLRouter router, IResourceAdapter adapter) {
    auto base = prefix ~ "/" ~ adapter.path;

    router.get(base, (req, res) => guard(res, () {
      string[string] filters;
      foreach (key, value; req.query.byKeyValue)
        if (!key.startsWith("$"))
          filters[key] = value;
      auto items = adapter.list(identityOf(req).tenantId, filters);
      auto arr = Json.emptyArray;
      foreach (i; items)
        arr ~= i;
      writeJson(res, 200, Json.emptyObject.set("items", arr).set("count", items.length));
    }));

    router.post(base, (req, res) => guard(res, () {
      auto who = identityOf(req);
      auto created = adapter.create(who, registry.withReferences(who.tenantId, body(req)));
      res.headers["Location"] = base ~ "/" ~ created["id"].get!string;
      writeJson(res, 201, created);
    }));

    router.get(base ~ "/:id", (req, res) => guard(res, () {
      auto row = adapter.get(identityOf(req).tenantId, req.params["id"]);
      if (row.type == Json.Type.null_)
        throw new ResourceError(404, "NotFound", adapter.typeName ~ " '" ~ req.params["id"] ~ "' not found");
      writeJson(res, 200, row);
    }));

    auto updateHandler = (HTTPServerRequest req, HTTPServerResponse res) => guard(res, () {
      auto who = identityOf(req);
      writeJson(res, 200, adapter.update(who, req.params["id"], registry.withReferences(who.tenantId, body(req))));
    });
    router.patch(base ~ "/:id", updateHandler);
    router.put(base ~ "/:id", updateHandler);

    router.delete_(base ~ "/:id", (req, res) => guard(res, () {
      adapter.remove(identityOf(req), req.params["id"]);
      res.statusCode = 204;
      res.writeVoidBody();
    }));

    router.post(base ~ "/:id/:action", (req, res) => guard(res, () {
      auto params = req.contentType == "application/json" ? body(req) : Json.emptyObject;
      writeJson(res, 200, adapter.invoke(identityOf(req), req.params["id"], req.params["action"], params));
    }));
  }

  /// GET /api/v1/resources — the catalogue (paths, fields, actions).
  void handleCatalog(HTTPServerRequest req, HTTPServerResponse res) {
    auto list = Json.emptyArray;
    foreach (a; registry.adapters) {
      auto fields = Json.emptyArray;
      foreach (f; a.inputFields) {
        auto j = Json.emptyObject;
        j["name"] = f.name;
        j["kind"] = enumText(f.kind);
        j["label"] = f.label;
        if (f.options.length) {
          auto opts = Json.emptyArray;
          foreach (o; f.options)
            opts ~= Json(o);
          j["options"] = opts;
        }
        fields ~= j;
      }
      auto actions = Json.emptyArray;
      foreach (act; a.actions) {
        auto parameters = Json.emptyArray;
        foreach (param; act.parameters)
          parameters ~= Json(param);
        auto action = Json.emptyObject.set("name", act.name).set("label", act.label).set("odataAction", act.odataName);
        action["parameters"] = parameters;
        actions ~= action;
      }
      list ~= Json.emptyObject
        .set("path", prefix ~ "/" ~ a.path)
        .set("title", a.title)
        .set("odataEntitySet", a.setName)
        .set("parentField", a.parentField)
        .set("inputFields", fields)
        .set("actions", actions);
    }
    writeJson(res, 200, Json.emptyObject.set("items", list));
  }

  // ── helpers ────────────────────────────────────────────────────────────

  protected RequestIdentity identityOf(HTTPServerRequest req) {
    return resolveIdentity(req.headers.get("Authorization", ""), req.headers.get("X-Tenant-Id", ""),
      req.headers.get("X-User-Id", ""), defaultTenant);
  }

  protected static Json body(HTTPServerRequest req) {
    Json b;
    try
      b = req.json;
    catch (Exception e)
      throw new ResourceError(400, "InvalidPayload", "Request body is not valid JSON: " ~ e.msg);
    if (b.type == Json.Type.undefined || b.type == Json.Type.null_)
      return Json.emptyObject;
    if (b.type != Json.Type.object)
      throw new ResourceError(400, "InvalidPayload", "Request body must be a JSON object");
    return b;
  }

  protected static void guard(HTTPServerResponse res, scope void delegate() @safe action) {
    try
      action();
    catch (ResourceError e)
      writeError(res, e.status, e.code, e.msg);
    catch (Exception e) {
      logError("abap rest: %s", e.msg);
      writeError(res, 500, "InternalError", e.msg);
    }
  }

  protected static void writeJson(HTTPServerResponse res, int status, Json payload) {
    res.writeBody(payload.toString, status, "application/json; charset=utf-8");
  }

  protected static void writeError(HTTPServerResponse res, int status, string code, string message) {
    auto err = Json.emptyObject.set("code", code).set("message", message);
    writeJson(res, status, Json.emptyObject.set("error", err));
  }
}
