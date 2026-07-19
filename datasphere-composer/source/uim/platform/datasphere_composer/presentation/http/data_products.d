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

  this(ManageDataProductsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/composer/products", &handleList);
    router.get("/api/v1/composer/products/*", &handleGet);
    router.post("/api/v1/composer/products", &handleCreate);
    router.put("/api/v1/composer/products/*", &handleUpdate);
    router.delete_("/api/v1/composer/products/*", &handleDelete);
    router.get("/api/v1/composer/providers/*/products", &handleListByProvider);
  }

  void handleList(HTTPServerRequest req, HTTPServerResponse res) {
    auto items = usecase.list(req.getTenantId);
    auto arr = Json.emptyArray;
    foreach (item; items)
      arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int)HTTPStatus.ok);
  }

  void handleListByProvider(HTTPServerRequest req, HTTPServerResponse res) {
    auto tenantId = tenantId;
    auto path = req.requestPath.to!string;
    // path: /api/v1/composer/providers/<id>/products
    auto parts = path.split("/");
    string providerId = parts.length >= 6 ? parts[5] : "";
    auto items = usecase.listByProvider(tenantId, providerId);
    auto arr = Json.emptyArray;
    foreach (item; items)
      arr ~= item.toJson();
    res.writeJsonBody(arr, cast(int)HTTPStatus.ok);
  }

  void handleGet(HTTPServerRequest req, HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestPath.to!string);
    auto item = usecase.getById(tenantId, id);
    if (item.isNull) {
      writeError(res, 404, "Data product not found");
      return;
    }
    res.writeJsonBody(item.toJson(), cast(int)HTTPStatus.ok);
  }

  void handleCreate(HTTPServerRequest req, HTTPServerResponse res) {
    auto data = precheck.data;
    CreateDataProductRequest r;
    r.tenantId = tenantId;
    r.id = precheck.id;
    r.providerId = data.getString("providerId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.schemaVersion = data.getString("schemaVersion");
    r.namespace = data.getString("namespace");
    r.enabled = data.getBoolean("enabled");
    auto result = usecase.create(r);
    if (result.hasError)
      return writeError(res, 400, result.message);
    auto resp = Json.emptyObject;
    resp["id"] = Json(result.id);
    res.writeJsonBody(resp, cast(int)HTTPStatus.created);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
        auto id = DataProductId(precheck.id);
        if (id.isNull)
            return errorResponse("Invalid data product ID", 400);

    auto data = precheck.data;
    UpdateDataProductRequest r;
    r.tenantId = tenantId;
    r.productId = id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.status = data.getString("status");
    r.enabled = data.getBoolean("enabled");
    auto result = usecase.update(r);
    if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Data product updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;

    auto result = usecase.remove(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data product deleted successfully", 200, responseData);
  }
}
