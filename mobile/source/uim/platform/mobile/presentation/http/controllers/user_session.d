/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.user_session;
// import uim.platform.mobile.application.usecases.manage.user_sessions;
// import uim.platform.mobile.application.dto;
// import uim.platform.mobile.presentation.http
// import uim.platform.mobile;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

class UserSessionController : ManageHttpController {
  private ManageUserSessionsUseCase usecase;

  this(ManageUserSessionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/sessions", &handleCreate);
    router.get("/api/v1/sessions", &handleList);
    router.get("/api/v1/sessions/*", &handleGet);
    router.post("/api/v1/sessions/*/terminate", &handleTerminate);
    router.delete_("/api/v1/sessions/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateUserSessionRequest r;
    r.tenantId = tenantId;
    r.appId = data.getString("appId");
    r.deviceId = data.getString("deviceId");
    r.userId = data.getString("userId");
    r.ipAddress = data.getString("ipAddress");
    r.userAgent = data.getString("userAgent");
    r.platform = data.getString("platform");
    r.appVersion = data.getString("appVersion");
    auto result = usecase.create(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("User session created successfully", "Created", 201, resp);
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
        .set("userId", item.userId)
        .set("platform", item.platform)
        .set("status", item.status);
    }

    auto resp = Json.emptyObject
      .set("items", items)
      .set("count", results.length);

    return successResponse("User sessions retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto result = usecase.get(id);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.data.id)
      .set("tenantId", result.data.tenantId)
      .set("appId", result.data.appId)
      .set("deviceId", result.data.deviceId)
      .set("userId", result.data.userId)
      .set("ipAddress", result.data.ipAddress)
      .set("userAgent", result.data.userAgent)
      .set("platform", result.data.platform)
      .set("appVersion", result.data.appVersion)
      .set("status", result.data.status);

    return successResponse("User session retrieved successfully", "Retrieved", 200, resp);
  }

  protected Json terminateHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto result = usecase.terminate(id);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("message", "User session terminated successfully");

    return successResponse("User session terminated successfully", "Terminated", 200, resp);
  }

  mixin(HandleTemplate!("handleTerminate", "terminateHandler"));

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = UserSessionId(precheck.id);
    auto result = usecase.delete(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("message", "User session deleted successfully");

    return successResponse("User session deleted successfully", "Deleted", 200, resp);
  }
}
