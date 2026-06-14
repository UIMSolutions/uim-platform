/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.push_registration;
// import uim.platform.mobile.application.usecases.manage.push_registrations;
// import uim.platform.mobile.application.dto;
// import uim.platform.mobile;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

class PushRegistrationController : ManageHttpController {
  private ManagePushRegistrationsUseCase usecase;

  this(ManagePushRegistrationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/push/registrations", &handleRegister);
    router.get("/api/v1/push/registrations", &handleList);
    router.get("/api/v1/push/registrations/*", &handleGet);
    router.delete_("/api/v1/push/registrations/*", &handleDelete);
  }

  protected Json registerHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    RegisterPushRequest r;
    r.tenantId = tenantId;
    r.appId = data.getString("appId");
    r.deviceId = data.getString("deviceId");
    r.provider = data.getString("provider");
    r.pushToken = data.getString("pushToken");
    r.topics = data.getStrings("topics");
    auto result = usecase.register(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Push registration successful", "Created", 201, resp);
  }

  protected void handleRegister(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = registerHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
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
        .set("deviceId", item.deviceId)
        .set("provider", item.provider)
        .set("status", item.status);
    }
    auto resp = Json.emptyObject
      .set("items", items)
      .set("totalCount", Json(results.length));

    return successResponse("Push registrations retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PushRegistrationId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid push registration ID", 400);

    auto result = usecase.get(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", Json(result.data.id))
      .set("tenantId", Json(result.data.tenantId))
      .set("appId", Json(result.data.appId))
      .set("deviceId", Json(result.data.deviceId))
      .set("provider", Json(result.data.provider))
      .set("pushToken", Json(result.data.pushToken))
      .set("topics", toJsonArray(result.data.topics))
      .set("status", Json(result.data.status))
      .set("message", "Push registration retrieved successfully");

    return successResponse("Push registration retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = PushRegistrationId(precheck.id);
    auto result = usecase.deletePushRegistration(tenantId,id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("message", "Push registration deleted successfully");

    return successResponse("Push registration deleted successfully", "Deleted", 200, resp);
  }
}
