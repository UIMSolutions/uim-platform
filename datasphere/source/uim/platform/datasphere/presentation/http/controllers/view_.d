/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.view_;
// import uim.platform.datasphere.application.usecases.manage.views;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

class ViewController : ManageHttpController {
  protected ManageViewsUseCase usecase;

  this(ManageViewsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/datasphere/views", &handleList);
    router.get("/api/v1/datasphere/views/*", &handleGet);
    router.post("/api/v1/datasphere/views", &handleCreate);
    router.put("/api/v1/datasphere/views/*", &handleUpdate);
    router.delete_("/api/v1/datasphere/views/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;

    CreateViewRequest r;
    r.tenantId = tenantId;
    r.spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.businessName = data.getString("businessName");
    r.semantic = data.getString("semantic");
    r.sqlExpression = data.getString("sqlExpression");
    r.isExposed = data.getBoolean("isExposed", false);

    auto now = Clock.currTime();
    // r.createdAt = now;
    // r.updatedAt = now;

    auto result = usecase.createView(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
      
    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("DataView created successfully", "Created", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
    auto views = usecase.listViews(tenantId, spaceId);

    auto list = Json.emptyArray;
    foreach (v; views) {
      list ~= Json.emptyObject
        .set("id", v.id)
        .set("name", v.name)
        .set("description", v.description)
        .set("businessName", v.businessName)
        .set("isExposed", v.isExposed)
        .set("isPersisted", v.isPersisted)
        .set("rowCount", v.rowCount)
        .set("createdAt", v.createdAt);
    }

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Views retrieved successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DataViewId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid view ID", 400);

    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
    auto v = usecase.getView(tenantId, spaceId, id);
    if (v.isNull)
      return errorResponse("DataView not found", 404);

    auto resp = Json.emptyObject
      .set("id", v.id)
      .set("name", v.name)
      .set("description", v.description)
      .set("businessName", v.businessName)
      .set("sqlExpression", v.sqlExpression)
      .set("isExposed", v.isExposed)
      .set("isPersisted", v.isPersisted)
      .set("rowCount", v.rowCount)
      .set("createdAt", v.createdAt)
      .set("updatedAt", v.updatedAt);

    return successResponse("DataView retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    UpdateViewRequest r;
    r.tenantId = tenantId;
    r.spaceId = SpaceId(  req.headers.get("X-Space-Id", ""));
    r.viewId = DataViewId(precheck.id);
    r.name = data.getString(  "name");
    r.description = data.getString("description");
    r.businessName = data.getString(  "businessName");
    r.sqlExpression = data.getString("sqlExpression");
    r
      .isExposed = data.getBoolean("isExposed", false);
    r.isPersisted = data.getBoolean(  "isPersisted", false);
    auto result = usecase.updateView(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("DataView updated successfully", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto spaceId = SpaceId(req.headers.get("X-Space-Id", ""));
    auto id = DataViewId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid view ID", 400);

    auto result = usecase.deleteView(tenantId, spaceId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("DataView deleted successfully", 204, responseData);
  }
}
