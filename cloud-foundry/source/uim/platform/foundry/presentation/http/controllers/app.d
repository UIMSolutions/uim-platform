/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.presentation.http.controllers.app;

// import uim.platform.foundry.application.usecases.manage.apps;
// import uim.platform.foundry.application.dto;


import uim.platform.foundry;

mixin(ShowModule!());

@safe:
class AppController : ManageHttpController {
  private ManageAppsUseCase useCase;

  this(ManageAppsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/apps", &handleCreate);
    router.get("/api/v1/apps", &handleList);
    // Action routes (more specific — registered before wildcard)
    router.post("/api/v1/apps/start/*", &handleStart);
    router.post("/api/v1/apps/stop/*", &handleStop);
    router.post("/api/v1/apps/restart/*", &handleRestart);
    router.post("/api/v1/apps/scale/*", &handleScale);
    router.get("/api/v1/apps/env/*", &handleEnv);
    router.put("/api/v1/apps/env/*", &handleSetEnv);
    // CRUD wildcard
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
    auto r = CreateAppRequest();
    r.tenantId = tenantId;
    r.spaceId = data.getString("spaceId");
    r.name = data.getString("name");
    r.instances = data.getInteger("instances", 0);
    r.memoryMb = data.getInteger("memoryMb");
    r.diskMb = data.getInteger("diskMb");
    r.buildpackId = data.getString("buildpackId");
    r.stack = data.getString("stack");
    r.command = data.getString("command");
    r.healthCheckType = data.getString("healthCheckType");
    r.healthCheckEndpoint = data.getString("healthCheckEndpoint");
    r.healthCheckTimeoutSec = data.getInteger("healthCheckTimeoutSec", 0);
    r.environmentVariables = data.getString("environmentVariables");
    r.dockerImage = data.getString("dockerImage");
    r.createdBy = UserId(data.getString("createdBy"));

    auto result = useCase.createApp(r);
    if(result.hasError)
    return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Application created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto apps = useCase.listApps(tenantId);
    auto list = apps.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Application list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AppId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid application ID", 400);

    auto app = useCase.getApp(tenantId, id);
    if (app.isNull)
      return errorResponse("Application not found", 404);

    auto responseData = app.toJson();
    return successResponse("Application retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AppId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid application ID", 400);

    auto data = precheck.data;
    auto r = UpdateAppRequest();
    r.appId = id;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.instances = data.getInteger("instances", 0);
    r.memoryMb = data.getInteger("memoryMb", 0);
    r.diskMb = data.getInteger("diskMb", 0);
    r.buildpackId = data.getString("buildpackId");
    r.stack = data.getString("stack");
    r.command = data.getString("command");
    r.healthCheckType = data.getString("healthCheckType");
    r.healthCheckEndpoint = data.getString("healthCheckEndpoint");
    r.healthCheckTimeoutSec = data.getInteger("healthCheckTimeoutSec", 0);
    r.environmentVariables = data.getString("environmentVariables");
    r.dockerImage = data.getString("dockerImage");

    auto result = useCase.updateApp(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Application updated successfully", "Updated", 200, responseData);
  }

  protected Json startHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AppId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid application ID", 400);

    auto result = useCase.startApp(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Application started successfully", "Started", 200, responseData);
  }

  mixin(HandleTemplate!("handleStart", "startHandler"));

  protected Json stopHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AppId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid application ID", 400);

    auto result = useCase.stopApp(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Application stopped successfully", "Stopped", 200, responseData);
  }

  mixin(HandleTemplate!("handleStop", "stopHandler"));

  protected Json restartHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AppId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid application ID", 400);

    auto result = useCase.restartApp(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Application restarted successfully", "Restarted", 200, responseData);
  }

  mixin(HandleTemplate!("handleRestart", "restartHandler"));

  protected Json scaleHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AppId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid application ID", 400);

    auto data = precheck.data;
    auto r = ScaleAppRequest();
    r.appId = id;
    r.tenantId = tenantId;
    r.instances = data.getInteger("instances", 0);
    r.memoryMb = data.getInteger("memoryMb", 0);
    r.diskMb = data.getInteger("diskMb", 0);

    auto result = useCase.scaleApp(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Application scaled successfully", "Scaled", 200, responseData);
  }

  mixin(HandleTemplate!("handleScale", "scaleHandler"));

  protected Json envHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AppId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid application ID", 400);

    auto env = useCase.getEnvironment(tenantId, id);

    auto responseData = Json.emptyObject
      .set("appId", id)
      .set("environmentVariables", env);

    return successResponse("Application environment variables retrieved successfully", "Retrieved", 200, responseData);
  }

  mixin(HandleTemplate!("handleEnv", "envHandler"));

  protected Json setEnvHandler(HTTPServerRequest req) {
    auto precheck = super.putHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AppId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid application ID", 400);

    auto data = precheck.data;
    auto envJson = data.getString("environmentVariables");

    auto result = useCase.setEnvironment(tenantId, id, envJson);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Application environment variables updated successfully", "Updated", 200, responseData);
  }

  mixin(HandleTemplate!("handleSetEnv", "setEnvHandler"));

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = AppId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid application ID", 400);

    auto result = useCase.deleteApp(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Application deleted successfully", "Deleted", 200, responseData);
  }
}
