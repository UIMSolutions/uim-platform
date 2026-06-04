/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.presentation.http.data_products;

import uim.platform.datasphere_composer;
import vibe.http.server;
import vibe.http.router;


mixin(ShowModule!());

@safe:
class DataProductController : ManageHttpController {
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
    auto tenantId  = tenantId;
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
    auto item = usecase.getById(tenantId, id);
    if (item.isNull) { writeError(res, 404, "Data product not found"); return; }
    res.writeJsonBody(item.toJson(), cast(int) HTTPStatus.ok);
  }

  void handleCreate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    CreateDataProductRequest r;
    r.tenantId     = tenantId;
    r.id           = precheck.id;
    r.providerId   = data.getString("providerId");
    r.name         = data.getString("name");
    r.description  = data.getString("description");
    r.schemaVersion = data.getString("schemaVersion");
    r.namespace    = data.getString("namespace");
    r.enabled      = data.getBoolean("enabled");
    auto result = usecase.create(r);
    if (!result.success) { writeError(res, 400, result.message); return; }
    auto resp = Json.emptyObject;
    resp["id"] = Json(result.id);
    res.writeJsonBody(resp, cast(int) HTTPStatus.created);
  }

  void handleUpdate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    UpdateDataProductRequest r;
    r.tenantId    = tenantId;
    r.id          = extractIdFromPath(req.requestPath.to!string);
    r.name        = data.getString("name");
    r.description = data.getString("description");
    r.status      = data.getString("status");
    r.enabled     = data.getBoolean("enabled");
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
