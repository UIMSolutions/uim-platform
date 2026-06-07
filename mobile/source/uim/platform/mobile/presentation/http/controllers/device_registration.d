/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.device_registration;
// import uim.platform.mobile.application.usecases.manage.device_registrations;
// import uim.platform.mobile.application.dto;
// import uim.platform.mobile;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

class DeviceRegistrationController : ManageHttpController {
  private ManageDeviceRegistrationsUseCase usecase;

  this(ManageDeviceRegistrationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/devices", &handleRegister);
    router.get("/api/v1/devices", &handleList);
    router.get("/api/v1/devices/*", &handleGet);
    router.put("/api/v1/devices/*/status", &handleUpdateStatus);
    router.delete_("/api/v1/devices/*", &handleDelete);
  }

  protected Json registerHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    RegisterDeviceRequest r;
    r.tenantId = tenantId;
    r.appId = data.getString("appId");
    r.deviceModel = data.getString("deviceModel");
    r.osVersion = data.getString("osVersion");
    r.appVersion = data.getString("appVersion");
    r.platform = data.getString("platform");
    r.userId = data.getString("userId");
    r.deviceToken = data.getString("deviceToken");
    auto result = usecase.register(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Device registered successfully", "Created", 201, resp);
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
        .set("deviceModel", item.deviceModel)
        .set("platform", item.platform)
        .set("status", item.status);
    }
    auto resp = Json.emptyObject
      .set("items", items)
      .set("totalCount", results.length);

    return successResponse("Device registrations retrieved successfully", "Retrieved", 200, resp);
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
      .set("deviceModel", result.data.deviceModel)
      .set("osVersion", result.data.osVersion)
      .set("appVersion", result.data.appVersion)
      .set("platform", result.data.platform)
      .set("userId", result.data.userId)
      .set("deviceToken", result.data.deviceToken)
      .set("status", result.data.status);

    return successResponse("Device registration retrieved successfully", "Retrieved", 200, resp);
  }

  protected Json updateStatusHandler(HTTPServerRequest req) {
    auto precheck = super.putHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto data = precheck.data;
    auto status = data.getString("status");
    auto result = usecase.updateStatus(id, status);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id);

    return successResponse("Device registration status updated successfully", "Updated", 200, resp);
  }

  protected void handleUpdateStatus(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = updateStatusHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto result = usecase.deleteDeviceRegistration(DeviceRegistrationId(id));
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Device registration deleted successfully", "Deleted", 204, Json
        .emptyObject);
  }
}
