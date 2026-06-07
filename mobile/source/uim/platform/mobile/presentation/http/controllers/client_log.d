/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.client_log;
// import uim.platform.mobile.application.usecases.manage.client_logs;
// import uim.platform.mobile.application.dto;
// import uim.platform.mobile;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:
class ClientLogController : ManageHttpController {
  private ManageClientLogsUseCase usecase;

  this(ManageClientLogsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/logs", &handleUpload);
    router.get("/api/v1/logs", &handleList);
    router.get("/api/v1/logs/*", &handleGet);
  }

  protected Json uploadHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    UploadClientLogRequest r;
    r.tenantId = tenantId;
    r.appId = data.getString("appId");
    r.deviceId = data.getString("deviceId");
    r.userId = data.getString("userId");
    r.level = data.getString("level");
    r.source = data.getString("source");
    r.message = data.getString("message");
    r.stackTrace = data.getString("stackTrace");
    r.metadata = data.getString("metadata");
    r.platform = data.getString("platform");
    r.appVersion = data.getString("appVersion");
    r.timestamp = data.getLong("timestamp");
    auto result = usecase.upload(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject
      .set("id", result.id);
  }

  protected void handleUpload(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = uploadHandler(req);
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
        .set("level", item.level)
        .set("source", item.source)
        .set("message", item.message);
    }

    auto resp = Json.emptyObject
      .set("items", items)
      .set("totalCount", results.length);

    return successResponse("Client logs retrieved successfully", "Retrieved", 200, resp);
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
      .set("level", result.data.level)
      .set("source", result.data.source)
      .set("message", result.data.message)
      .set("stackTrace", result.data.stackTrace)
      .set("metadata", result.data.metadata)
      .set("platform", result.data.platform)
      .set("appVersion", result.data.appVersion)
      .set("timestamp", result.data.timestamp)
      .set("message", "Client log retrieved successfully");

    return successResponse("Client log retrieved successfully", "Retrieved", 200, resp);
  }
}
