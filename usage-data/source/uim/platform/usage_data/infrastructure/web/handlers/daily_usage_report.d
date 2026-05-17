/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.usage_data.infrastructure.web.handlers.daily_usage_report;

import uim.platform.usage_data;

mixin(ShowModule!());
@safe:

class DailyUsageReportHandler {
  private DailyUsageReportUseCases useCases;

  this(DailyUsageReportUseCases useCases) {
    this.useCases = useCases;
  }

  void getAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto items = useCases.listReports(TenantId.init);
    Json jArr = Json.emptyArray;
    foreach (item; items) jArr ~= toJsonValue(item);
    res.writeJsonBody(jArr);
  }

  void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI);
    if (id.length == 0) {
      res.writeJsonBody(errorJson("Missing report id"), 400);
      return;
    }
    auto item = useCases.getReport(TenantId.init, DailyUsageReportId(id));
    if (item.isEmpty) {
      res.writeJsonBody(errorJson("Daily usage report not found", 404), 404);
      return;
    }
    res.writeJsonBody(toJsonValue(item));
  }

  void create(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto json = req.json;
      auto cmd = CreateDailyUsageReportRequest(
        json["globalAccountId"].get!string,
        json["subaccountId"].get!string,
        json["reportDate"].get!string,
      );
      res.writeJsonBody(toJsonValue(useCases.createReport(cmd)), 201);
    } catch (Exception e) {
      res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), 400);
    }
  }

  void markReady(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI);
    auto result = useCases.markReady(TenantId.init, DailyUsageReportId(id));
    if (result.isEmpty) {
      res.writeJsonBody(errorJson("Daily usage report not found", 404), 404);
      return;
    }
    res.writeJsonBody(toJsonValue(result));
  }

  void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI);
    useCases.deleteReport(TenantId.init, DailyUsageReportId(id));
    res.writeJsonBody(Json.emptyObject, 204);
  }
}
