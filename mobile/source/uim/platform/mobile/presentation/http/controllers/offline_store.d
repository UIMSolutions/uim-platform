/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.offline_store;
// import uim.platform.mobile.application.usecases.manage.offline_stores;
// import uim.platform.mobile.application.dto;
// import uim.platform.mobile;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

class OfflineStoreController : ManageHttpController {
  private ManageOfflineStoresUseCase usecase;

  this(ManageOfflineStoresUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/offline-stores", &handleCreate);
    router.get("/api/v1/offline-stores", &handleList);
    router.get("/api/v1/offline-stores/*", &handleGet);
    router.put("/api/v1/offline-stores/*", &handleUpdate);
    router.delete_("/api/v1/offline-stores/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateOfflineStoreRequest r;
    r.tenantId = tenantId;
    r.appId = data.getString("appId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.storeType = data.getString("storeType");
    r.syncPolicy = data.getString("syncPolicy");
    r.createdBy = UserId(data.getString("createdBy"));
    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Offline store created successfully", "Created", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto results = usecase.list(tenantId);
    auto items = Json.emptyArray;
    foreach (item; results) {
      items ~= Json.emptyObject
        .set("id", item.id)
        .set("appId", item.appId)
        .set("name", item.name)
        .set("storeType", item.storeType)
        .set("status", item.status);
    }

    auto resp = Json.emptyObject
      .set("items", items)
      .set("count", results.length);

    return successResponse("Offline stores retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = OfflineStoreId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid offline store ID", 400);

    auto result = usecase.get(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", Json(result.data.id))
      .set("tenantId", Json(result.data.tenantId))
      .set("appId", Json(result.data.appId))
      .set("name", Json(result.data.name))
      .set("description", Json(result.data.description))
      .set("storeType", Json(result.data.storeType))
      .set("syncPolicy", Json(result.data.syncPolicy))
      .set("status", Json(result.data.status))
      .set("createdBy", Json(result.data.createdBy))
      .set("message", "Offline store retrieved successfully");

    return successResponse("Offline store retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = OfflineStoreId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid offline store ID", 400);

    auto data = precheck.data;
    UpdateOfflineStoreRequest r;
    r.tenantId = tenantId;
    r.storeId = id;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.syncPolicy = data.getString("syncPolicy");
    r.status = data.getString("status");
    r.updatedBy = UserId(data.getString("updatedBy"));
    auto result = usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Offline store updated successfully", "Updated", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = OfflineStoreId(precheck.id);
    auto result = usecase.deleteOfflineStore(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Offline store deleted successfully", "Deleted", 204, result);
  }
}
