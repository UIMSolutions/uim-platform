/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.mobile_app;
// import uim.platform.mobile.application.usecases.manage.mobile_apps;
// import uim.platform.mobile.application.dto;
// import uim.platform.mobile;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

class MobileAppController : ManageHttpController {
  private ManageMobileAppsUseCase usecase;

  this(ManageMobileAppsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/apps", &handleCreate);
    router.get("/api/v1/apps", &handleList);
    router.get("/api/v1/apps/*", &handleGet);
    router.put("/api/v1/apps/*", &handleUpdate);
    router.delete_("/api/v1/apps/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateMobileAppRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.bundleId = data.getString("bundleId");
    r.platform = data.getString("platform");
    r.securityConfig = data.getString("securityConfig");
    r.authProvider = data.getString("authProvider");
    r.pushEnabled = data.getBoolean("pushEnabled");
    r.offlineEnabled = data.getBoolean("offlineEnabled");
    r.iconUrl = data.getString("iconUrl");
    r.createdBy = UserId(data.getString("createdBy"));
    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Mobile app created successfully", "Created", 201, resp);
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
        .set("name", item.name)
        .set("bundleId", item.bundleId)
        .set("platform", item.platform)
        .set("status", item.status);
    }
    auto resp = Json.emptyObject
      .set("items", items)
      .set("totalCount", Json(results.length));

    return successResponse("Mobile apps retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = MobileAppId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid mobile app ID", 400);

    auto result = usecase.get(id);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.data.id)
      .set("tenantId", result.data.tenantId)
      .set("name", result.data.name)
      .set("description", result.data.description)
      .set("bundleId", result.data.bundleId)
      .set("platform", result.data.platform)
      .set("securityConfig", result.data.securityConfig)
      .set("authProvider", result.data.authProvider)
      .set("pushEnabled", result.data.pushEnabled)
      .set("offlineEnabled", result.data.offlineEnabled)
      .set("iconUrl", result.data.iconUrl)
      .set("status", result.data.status)
      .set("createdBy", result.data.createdBy)
      .set("message", "Mobile app retrieved successfully");

    return successResponse("Mobile app retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = MobileAppId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid mobile app ID", 400);

    auto data = precheck.data;
    UpdateMobileAppRequest r;
    r.id = id;
    r.description = data.getString("description");
    r.securityConfig = data.getString("securityConfig");
    r.authProvider = data.getString("authProvider");
    r.status = data.getString("status");
    r.pushEnabled = data.getBoolean("pushEnabled");
    r.offlineEnabled = data.getBoolean("offlineEnabled");
    r.iconUrl = data.getString("iconUrl");
    r.updatedBy = UserId(data.getString("updatedBy"));
    auto result = usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("message", "Mobile app updated successfully");

    return successResponse("Mobile app updated successfully", "Updated", 200, resp);
    }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = MobileAppId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid mobile app ID", 400);

    auto result = usecase.deleteMobileApp(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id);
    return successResponse("Mobile app deleted successfully", "Deleted", 200, resp);

  }
}
