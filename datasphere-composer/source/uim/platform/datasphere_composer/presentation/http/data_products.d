/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.presentation.http.data_products;

import uim.platform.datasphere_composer;
import vibe.http.server;
import vibe.http.router;
import std.conv : to;

mixin(ShowModule!());

@safe:
class DataProductController : ManageController {
  private ManageDataProductsUseCase usecase;

  this(ManageDataProductsUseCase usecase) { this.usecase = usecase; }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/composer/products",              &handleList);
    router.get("/api/v1/composer/products/*",            &handleGet);
    router.post("/api/v1/composer/products",             &handleCreate);
    router.put("/api/v1/composer/products/*",            &handleUpdate);
    router.delete_("/api/v1/composer/products/*",        &handleDelete);
    router.get("/api/v1/composer/providers/*/products",  &handleListByProvider);
  }

  void handleList(HTTPServerRequest req, HTTPServerResponse res) {
    auto items = usecase.list(req.getTenantId);
    auto arr = Json.emptyArray;
    foreach (item; items) arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  void handleListByProvider(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId  = req.getTenantId;
    auto path      = req.requestPath.to!string;
    // path: /api/v1/composer/providers/<id>/products
    auto parts = path.split("/");
    string providerId = parts.length >= 6 ? parts[5] : "";
    auto items = usecase.listByProvider(tenantId, providerId);
    auto arr = Json.emptyArray;
    foreach (item; items) arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int) HTTPStatus.ok);
  }

  void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
    auto id   = extractIdFromPath(req.requestPath.to!string);
    auto item = usecase.getById(req.getTenantId, id);
    if (item.isNull) { writeError(res, 404, "Data product not found"); return; }
    res.writeJsonBody(item.toJson(), cast(int) HTTPStatus.ok);
  }

  void handleCreate(HTTPServerRequest req, HTTPServerResponse res) {
    auto j = req.json;
    CreateDataProductRequest r;
    r.tenantId     = req.getTenantId;
    r.id           = j.getString("id");
    r.providerId   = j.getString("providerId");
    r.name         = j.getString("name");
    r.description  = j.getString("description");
    r.schemaVersion = j.getString("schemaVersion");
    r.namespace    = j.getString("namespace");
    r.enabled      = j.getBoolean("enabled");
    auto result = usecase.create(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    auto resp = Json.emptyObject;
    resp["id"] = Json(result.id);
    res.writeJsonBody(resp, cast(int) HTTPStatus.created);
  }

  void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) {
    auto j = req.json;
    UpdateDataProductRequest r;
    r.tenantId    = req.getTenantId;
    r.id          = extractIdFromPath(req.requestPath.to!string);
    r.name        = j.getString("name");
    r.description = j.getString("description");
    r.status      = j.getString("status");
    r.enabled     = j.getBoolean("enabled");
    auto result = usecase.update(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }

  void handleDelete(HTTPServerRequest req, HTTPServerResponse res) {
    auto result = usecase.remove(req.getTenantId, extractIdFromPath(req.requestPath.to!string));
    if (!result.success) { writeError(res, 404, result.message); return; }
    res.writeJsonBody(Json.emptyObject, cast(int) HTTPStatus.ok);
  }
}
