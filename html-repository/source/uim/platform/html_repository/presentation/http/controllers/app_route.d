/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.app_route;
// import uim.platform.html_repository.application.usecases.manage.app_routes;
// import uim.platform.html_repository.application.dto;
// import uim.platform.htmls;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class AppRouteController : ManageHttpController {
  protected ManageAppRoutesUseCase usecase;

  this(ManageAppRoutesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/routes", &handleCreate);
    router.get("/api/v1/routes", &handleList);
    router.get("/api/v1/routes/*", &handleGet);
    router.put("/api/v1/routes/*", &handleUpdate);
    router.delete_("/api/v1/routes/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateAppRouteRequest request;
    request.tenantId = tenantId;
    request.routeId = AppRouteId(data.getString("routeId", ""));
    request.appId = HtmlAppId(data.getString("appId"));
    request.pathPrefix = data.getString("pathPrefix");
    request.targetUrl = data.getString("targetUrl");
    request.description = data.getString("description");
    request.createdBy = UserId(data.getString("createdBy"));

    auto result = usecase.createAppRoute(request);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Route created successfully", "Created", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = usecase.listAppRoutes(tenantId);
    auto arr = Json.emptyArray;
    foreach (e; items) {
      arr ~= Json.emptyObject
        .set("id", e.id.value)
        .set("appId", e.appId.value)
        .set("pathPrefix", e.pathPrefix)
        .set("status", e.status.toString());
    }

    auto resp = Json.emptyObject
      .set("items", arr)
      .set("totalCount", items.length);

    return successResponse("Routes retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = AppRouteId(precheck.id);
    if (id.isNull)
      return errorResponse("Route not found", 404);

    auto entry = usecase.getAppRoute(tenantId, id);
    if (entry.isNull)
      return errorResponse("Route not found", 404);

    auto response = Json.emptyObject
      .set("id", entry.id)
      .set("appId", entry.appId)
      .set("pathPrefix", entry.pathPrefix)
      .set("targetUrl", entry.targetUrl)
      .set("description", entry.description)
      .set("status", entry.status.toString())
      .set("createdBy", entry.createdBy)
      .set("createdAt", entry.createdAt)
      .set("updatedBy", entry.updatedBy)
      .set("updatedAt", entry.updatedAt);

    return successResponse("Route retrieved successfully", "Retrieved", 200, response);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto id = AppRouteId(precheck.id);
    if (id.isNull)
      return errorResponse("Route not found", 404);

    UpdateAppRouteRequest r;
    r.routeId = id;
    r.tenantId = tenantId;
    r.appId = HtmlAppId(data.getString("appId", ""));
    r.pathPrefix = data.getString("pathPrefix");
    r.description = data.getString("description");
    r.targetUrl = data.getString("targetUrl");
    r.status = data.getString("status");

    auto result = usecase.updateAppRoute(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", id);
    return successResponse("Route updated successfully", "Updated", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AppRouteId(precheck.id);
    if (id.isNull)
      return errorResponse("Route not found", 404);

    auto result = usecase.deleteAppRoute(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", id);

    return successResponse("Route deleted successfully", "Deleted", 200, resp);
  }
}