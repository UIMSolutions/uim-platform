/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.web.handlers.dashboard;

// import vibe.http.server;
// import vibe.data.json;
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
    auto items = useCases.list();
    res.writeJsonBody(toJsonArray(items));
  }

  void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractId(req);
    if (id.isEmpty) {
      res.writeJsonBody(errorJson("Missing dashboard id"), HTTPStatus.badRequest);
      return;
    }
    auto item = useCases.getById(id);
    if (item.isNull) {
      res.writeJsonBody(errorJson("Dashboard not found", 404), HTTPStatus.notFound);
      return;
    }
    res.writeJsonBody(toJsonValue(item));
  }

  void create(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto json = req.json;
      auto cmd = CreateDashboardRequest(json["name"].get!string,
          json["description"].get!string, json["ownerId"].get!string,);
      auto result = useCases.create(cmd);
      res.writeJsonBody(result.toJson, HTTPStatus.created);
    }
    catch (Exception e) {
      res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), HTTPStatus.badRequest);
    }
  }

  void addPage(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractId(req);
    try {
      auto json = req.json;
      auto result = useCases.addPage(id, json["title"].get!string);
      res.writeJsonBody(result.toJson);
    }
    catch (Exception e) {
      res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), HTTPStatus.badRequest);
    }
  }

  void publish(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractId(req);
    auto result = useCases.publish(id);
    if (result.isNull) {
      res.writeJsonBody(errorJson("Dashboard not found", 404), HTTPStatus.notFound);
      return;
    }
    res.writeJsonBody(result.toJson);
  }

  void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractId(req);
    useCases.remove(id);
    res.writeJsonBody(Json.emptyObject, HTTPStatus.noContent);
  }
}

