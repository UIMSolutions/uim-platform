/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// REST driving adapter (JSON over HTTP) for every resource of the registry —
/// the management plane. The prefix defaults to /api/v1/object-store.
///
///   GET    <prefix>/<resource>[?<field>=<value>…]     → { "items": [...], "count": n }
///   POST   <prefix>/<resource>                        → 201 created resource
///   GET    <prefix>/<resource>/<id>
///   PATCH  <prefix>/<resource>/<id>   (PUT accepted)  partial update
///   DELETE <prefix>/<resource>/<id>                   → 204
///   POST   <prefix>/<resource>/<id>/<action>          e.g. /objects/<id>/archive, /bindings/<id>/rotate
///   GET    <prefix>/buckets/<id|name>/list?prefix=&delimiter=/   S3 style listing with folders
///   POST   <prefix>/access/evaluate · /cors/check · /credentials/verify · /lifecycle/apply
///   GET    <prefix>/statistics · GET <prefix>/resources
///
/// Resources: buckets, objects, versions, policies, lifecycle-rules, cors-rules, bindings, regions, storage-classes.
/// Errors: { "error": { "code": "...", "message": "..." } } with 400/403/404/405/409/413/422/500.
/// Tenant / user come from the XSUAA token or the X-Tenant-Id / X-User-Id headers.
/// Bucket references (bucketId) accept an id or the bucket name.
module uim.platform.object_store.presentation.http.controllers.resources;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import uim.platform.object_store;
import uim.platform.object_store.presentation.resources;

mixin(ShowModule!());

@safe:

class ObjectStoreRestController {
  protected ResourceRegistry registry;
  protected string defaultTenant;
  protected string prefix;

  this(ResourceRegistry registry, string defaultTenant, string prefix = "/api/v1/object-store") {
    this.registry = registry;
    this.defaultTenant = defaultTenant;
    this.prefix = prefix;
  }

  void registerRoutes(URLRouter router) {
    router.get(prefix ~ "/resources", &handleCatalog);
    router.get(prefix ~ "/statistics", (req, res) => guard(res, () {
      writeJson(res, 200, registry.statistics(identityOf(req).tenantId));
    }));
    router.post(prefix ~ "/access/evaluate", (req, res) => guard(res, () {
      writeJson(res, 200, registry.evaluateAccess(identityOf(req).tenantId, body(req)));
    }));
    router.post(prefix ~ "/cors/check", (req, res) => guard(res, () {
      writeJson(res, 200, registry.checkCors(identityOf(req).tenantId, body(req)));
    }));
    router.post(prefix ~ "/credentials/verify", (req, res) => guard(res, () {
      writeJson(res, 200, registry.verifyCredentials(identityOf(req).tenantId, body(req)));
    }));
    router.post(prefix ~ "/lifecycle/apply", (req, res) => guard(res, () {
      writeJson(res, 200, registry.applyLifecycle(identityOf(req), body(req)));
    }));
    router.get(prefix ~ "/buckets/:id/list", (req, res) => guard(res, () {
      writeJson(res, 200, registry.listObjects(identityOf(req).tenantId, req.params["id"],
        req.query.get("prefix", ""), req.query.get("delimiter", "")));
    }));
    foreach (adapter; registry.adapters)
      registerResource(router, adapter);
  }

  /// One function call per adapter, so each closure captures its own adapter.
  protected void registerResource(URLRouter router, IResourceAdapter adapter) {
    auto base = prefix ~ "/" ~ adapter.path;

    router.get(base, (req, res) => guard(res, () {
      auto who = identityOf(req);
      auto query = Json.emptyObject;
      foreach (key, value; req.query.byKeyValue)
        if (!key.startsWith("$"))
          query[key] = value;
      string[string] filters;
      foreach (k, v; registry.withReferences(who.tenantId, query).get!(Json[string]))
        filters[k] = jsonText(v);
      auto items = adapter.list(who.tenantId, filters);
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
      auto who = identityOf(req);
      auto row = adapter.get(who.tenantId, idOf(adapter, who, req.params["id"]));
      if (row.type == Json.Type.null_)
        throw new ResourceError(404, "NotFound", adapter.typeName ~ " '" ~ req.params["id"] ~ "' not found");
      writeJson(res, 200, row);
    }));

    auto updateHandler = (HTTPServerRequest req, HTTPServerResponse res) => guard(res, () {
      auto who = identityOf(req);
      writeJson(res, 200, adapter.update(who, idOf(adapter, who, req.params["id"]),
        registry.withReferences(who.tenantId, body(req))));
    });
    router.patch(base ~ "/:id", updateHandler);
    router.put(base ~ "/:id", updateHandler);

    router.delete_(base ~ "/:id", (req, res) => guard(res, () {
      auto who = identityOf(req);
      adapter.remove(who, idOf(adapter, who, req.params["id"]));
      res.statusCode = 204;
      res.writeVoidBody();
    }));

    router.post(base ~ "/:id/:action", (req, res) => guard(res, () {
      auto who = identityOf(req);
      auto params = req.contentType == "application/json" ? body(req) : Json.emptyObject;
      writeJson(res, 200, adapter.invoke(who, idOf(adapter, who, req.params["id"]), req.params["action"],
        registry.withReferences(who.tenantId, params)));
    }));
  }

  /// GET <prefix>/resources — the catalogue (paths, fields, actions).
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
        .set("creatable", a.creatable)
        .set("updatable", a.updatable)
        .set("deletable", a.deletable)
        .set("readOnly", a.readOnly)
        .set("inputFields", fields)
        .set("actions", actions);
    }
    writeJson(res, 200, Json.emptyObject.set("items", list).set("contentApi", prefix ~ "/content/{bucket}/{key}"));
  }

  // ── helpers ────────────────────────────────────────────────────────────

  /// An id, or the id of the resource with that unique name (e.g. a bucket name).
  protected string idOf(IResourceAdapter adapter, RequestIdentity who, string idOrName) {
    try
      return registry.resolve(adapter, who.tenantId, idOrName);
    catch (ResourceError e) {
      if (e.status == 404)
        return idOrName; // the adapter reports it
      throw e;
    }
  }

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
}

/// Run a handler and answer errors as { "error": { "code", "message" } }.
void guard(HTTPServerResponse res, scope void delegate() @safe action) {
  try
    action();
  catch (ResourceError e)
    writeError(res, e.status, e.code, e.msg);
  catch (ObjectStoreException e)
    writeError(res, e.status, errorCodeOf(e.status), e.msg);
  catch (Exception e) {
    logError("object-store rest: %s", e.msg);
    writeError(res, 500, "InternalError", e.msg);
  }
}

void writeJson(HTTPServerResponse res, int status, Json payload) {
  res.writeBody(payload.toString, status, "application/json; charset=utf-8");
}

void writeError(HTTPServerResponse res, int status, string code, string message) {
  auto err = Json.emptyObject.set("code", code).set("message", message);
  writeJson(res, status, Json.emptyObject.set("error", err));
}
