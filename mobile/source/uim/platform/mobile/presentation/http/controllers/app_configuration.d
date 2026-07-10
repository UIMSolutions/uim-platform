/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.app_configuration;
// import uim.platform.mobile.application.usecases.manage.app_configurations;
// import uim.platform.mobile.application.dto;
// import uim.platform.mobile;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
class AppConfigurationController : ManageHttpController {
  private ManageAppConfigurationsUseCase usecase;

  this(ManageAppConfigurationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/configurations", &handleCreate);
    router.get("/api/v1/configurations", &handleList);
    router.get("/api/v1/configurations/*", &handleGet);
    router.put("/api/v1/configurations/*", &handleUpdate);
    router.delete_("/api/v1/configurations/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateAppConfigRequest r;
    r.tenantId = tenantId;
    r.appId = data.getString("appId");
    r.key = data.getString("key");
    r.value = data.getString("value");
    r.description = data.getString("description");
    r.isSecret = data.getBoolean("isSecret");
    r.platform = data.getString("platform");
    r.createdBy = UserId(data.getString("createdBy"));
    auto result = usecase.createAppConfiguration(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("App configuration created successfully", "Created", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto results = usecase.listAppConfigurations(tenantId);
    auto items = Json.emptyArray;
    foreach (item; results) {
      items ~= Json.emptyObject
        .set("id", item.id)
        .set("appId", item.appId)
        .set("key", item.key);
        // TODO: ? .set("platform", item.platform);
        // TODO: ? .set("status", item.status);
    }

    auto resp = Json.emptyObject
      .set("items", items)
      .set("totalCount", results.length);
    return successResponse("App configuration list retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AppConfigurationId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid app configuration ID", 400);

    auto config = usecase.getAppConfiguration(tenantId, id);
    if (config.isNull)
      return errorResponse("App configuration not found", 400);

    auto resp = Json.emptyObject
      .set("id", config.id)
      .set("tenantId", config.tenantId)
      .set("appId", config.appId)
      .set("key", config.key)
      .set("value", config.value)
      .set("description", config.description)
      .set("isSecret", config.isSecret)
      // TODO: .set("platform", config.platform)
      .set("createdBy", config.createdBy);

    return successResponse("App configuration retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AppConfigurationId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid app configuration ID", 400);

    auto data = precheck.data;
    UpdateAppConfigRequest r;
    r.configId = id;
    r.value = data.getString("value");
    r.description = data.getString("description");
    // TODO: ? r.isSecret = data.getBoolean("isSecret");
    // TODO: ? r.platform = data.getString("platform");
    r.updatedBy = UserId(data.getString("updatedBy"));
    auto result = usecase.updateAppConfiguration(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("App configuration updated successfully", "Updated", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AppConfigurationId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid app configuration ID", 400);

    auto result = usecase.deleteAppConfiguration(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("App configuration deleted successfully", "Deleted", 204, resp);
  }
}
