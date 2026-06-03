/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.web.handlers.dashboard;

// import uim.platform.analytics.app.usecases.dashboards;
// import uim.platform.analytics.app.dto.dashboard;

import uim.platform.analytics;

mixin(ShowModule!());
@safe:

class DashboardHandler {
  private DashboardUseCases useCases;

  this(DashboardUseCases useCases) {
    this.useCases = useCases;
  }

  void getAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto items = useCases.listDashboards();
    Json jArr = Json.emptyArray;
    foreach (item; items) jArr ~= toJsonValue(item);
    res.writeJsonBody(jArr);
  }

  void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = precheck.id;
    if (id.length == 0) {
      res.writeJsonBody(errorJson("Missing dashboard id"), 400);
      return;
    }
    auto item = useCases.getDashboard(TenantId.init, DashboardId(id));
    if (item.dashboardId.isEmpty) {
      res.writeJsonBody(errorJson("Dashboard not found", 404), 404);
      return;
    }
    res.writeJsonBody(toJsonValue(item));
  }

  void create(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto json = req.json;
      auto cmd = CreateDashboardRequest(json["name"].get!string,
          json["description"].get!string, json["ownerId"].get!string);
      auto result = useCases.createDashboard(cmd);
      res.writeJsonBody(toJsonValue(result), 201);
    }
    catch (Exception e) {
      res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), 400);
    }
  }

  void addPage(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = precheck.id;
    try {
      auto json = req.json;
      auto result = useCases.addPageToDashboard(TenantId.init, DashboardId(id), json["title"].get!string);
      res.writeJsonBody(toJsonValue(result));
    }
    catch (Exception e) {
      res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), 400);
    }
  }

  void publish(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = precheck.id;
    auto result = useCases.publishDashboard(TenantId.init, DashboardId(id));
    if (result.dashboardId.isEmpty) {
      res.writeJsonBody(errorJson("Dashboard not found", 404), 404);
      return;
    }
    res.writeJsonBody(toJsonValue(result));
  }

  void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = precheck.id;
    useCases.deleteDashboard(TenantId.init, DashboardId(id));
    res.writeJsonBody(Json.emptyObject, 204);
  }
}

