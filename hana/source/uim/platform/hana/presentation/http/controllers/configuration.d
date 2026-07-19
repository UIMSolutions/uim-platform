/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.presentation.http.controllers.configuration;
// import uim.platform.hana.application.usecases.manage.configurations;
// import uim.platform.hana.application.dto;

import uim.platform.hana;

mixin(ShowModule!());

@safe:

class ConfigurationController : ManageHttpController {
  private ManageConfigurationsUseCase usecase;

  this(ManageConfigurationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/api/v1/hana/configurations", &handleList);
    router.get("/api/v1/hana/configurations/*", &handleGet);
    router.post("/api/v1/hana/configurations", &handleCreate);
    router.put("/api/v1/hana/configurations/*", &handleUpdate);
    router.delete_("/api/v1/hana/configurations/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateConfigurationRequest r;
    r.tenantId = tenantId;
    r.instanceId = data.getString("instanceId");
    r.id = ConfigurationId(precheck.id);
    r.section = data.getString("section");
    r.key = data.getString("key");
    r.value = data.getString("value");
    r.scope_ = data.getString("scope");
    r.dataType = data.getString("dataType");
    r.description = data.getString("description");

    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Configuration created successfully", 201, resp);

  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto configs = usecase.list(tenantId);
    auto jarr = Json.emptyArray;
    foreach (c; configs) {
      jarr ~= Json.emptyObject
        .set("id", c.id)
        .set("instanceId", c.instanceId)
        .set("section", c.section)
        .set("key", c.key)
        .set("value", c.value)
        .set("isReadOnly", c.isReadOnly)
        .set("requiresRestart", c.requiresRestart);
    }

    auto resp = Json.emptyObject
      .set("count", configs.length)
      .set("resources", list);

    return successResponse("Configuration list retrieved successfully", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConfigurationId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid configuration ID", 400);

    auto c = usecase.getById(tenantId, id);
    if (c.isNull)
      return errorResponse("Configuration not found", 404);

    auto resp = Json.emptyObject
      .set("id", c.id)
      .set("instanceId", c.instanceId)
      .set("section", c.section)
      .set("key", c.key)
      .set("value", c.value)
      .set("defaultValue", c.defaultValue)
      .set("description", c.description)
      .set("isReadOnly", c.isReadOnly)
      .set("requiresRestart", c.requiresRestart)
      .set("updatedAt", c.updatedAt)
      .set("updatedBy", c.updatedBy);

    return successResponse("Configuration retrieved successfully", 200, resp);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConfigurationId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid configuration ID", 400);

    auto data = precheck.data;
    UpdateConfigurationRequest r;
    r.tenantId = tenantId;
    r.configId = id;
    r.value = data.getString("value");

    auto result = usecase.update(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Configuration updated successfully", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConfigurationId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid configuration ID", 400);

    auto result = usecase.deleteConfiguration(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Configuration deleted successfully", 200, Json
        .emptyObject.set("id", result.id));
  }
}
