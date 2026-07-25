/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.usage_report;
// import uim.platform.mobile.application.usecases.manage.usage_reports;
// import uim.platform.mobile.application.dto;
// import uim.platform.mobile;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

class UsageReportController : ManageHttpController {
  private ManageUsageReportsUseCase usecase;

  this(ManageUsageReportsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/usage", &handleReport);
    router.get("/api/v1/usage", &handleList);
    router.get("/api/v1/usage/*", &handleGet);
  }

  protected Json reportHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;
    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateUsageReportRequest r;
    r.tenantId = tenantId;
    r.appId = data.getString("appId");
    r.deviceId = data.getString("deviceId");
    r.userId = data.getString("userId");
    r.metricType = data.getString("metricType");
    r.metricKey = data.getString("metricKey");
    r.metricValue = data.getString("metricValue");
    r.sessionId = data.getString("sessionId");
    r.platform = data.getString("platform");
    r.appVersion = data.getString("appVersion");
    r.timestamp = data.getLong("timestamp");

    auto result = usecase.report(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Usage report created successfully", "Created", 201, resp);
  }

  mixin(HandleTemplate!("handleReport", "reportHandler"));

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto results = usecase.listUsageReports(tenantId);
    auto items = Json.emptyArray;
    foreach (item; results) {
      items ~= Json.emptyObject
        .set("id", item.id)
        .set("appId", item.appId)
        .set("metricType", item.metricType)
        .set("metricKey", item.metricKey)
        .set("metricValue", item.metricValue);
    }
    auto resp = Json.emptyObject
      .set("items", items)
      .set("total", results.length);

    return successResponse("Usage reports retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = UsageReportId(precheck.id);
    auto report = usecase.getUsageReport(tenantId, id);
    if (report.isNull)
      return errorResponse("Usage report not found", 400);

    auto responseData = Json.emptyObject
      .set("id", report.id)
      .set("tenantId", report.tenantId)
      .set("appId", report.appId)
      .set("deviceId", report.deviceId)
      .set("userId", report.userId)
      .set("metricType", report.metricType.toString)
      .set("metricKey", report.metricKey)
      .set("metricValue", report.metricValue)
      .set("sessionId", report.sessionId)
      .set("platform", report.platform)
      .set("appVersion", report.appVersion)
      .set("timestamp", report.timestamp);

    return successResponse("Usage report retrieved successfully", "Retrieved", 200, responseData);
  }
}
