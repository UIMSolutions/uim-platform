/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.web.handlers.planning;

// import vibe.http.server;
// import vibe.data.json;
// import uim.platform.analytics.app.usecases.planning;
// import uim.platform.analytics.app.dto.planning;

import uim.platform.analytics;

mixin(ShowModule!());
@safe:
class PlanningHandler {
  private PlanningUseCases useCases;

  this(PlanningUseCases useCases) {
    this.useCases = useCases;
  }

  void getAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    res.writeJsonBody(toJsonArray(useCases.list()));
  }

  void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI, "planning");
    if (id.isEmpty) {
      res.writeJsonBody(errorJson("Missing id"), HTTPStatus.badRequest);
      return;
    }
    auto item = useCases.getById(id);
    if (item.isNull) {
      res.writeJsonBody(errorJson("Not found", 404), HTTPStatus.notFound);
      return;
    }
    res.writeJsonBody(toJsonValue(item));
  }

  void create(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto json = req.json;
      auto cmd = CreatePlanningModelRequest(json["name"].get!string,
          json["description"].get!string, json["datasetId"].get!string,
          json["granularity"].get!string, json["userId"].get!string,);
      res.writeJsonBody(toJsonValue(useCases.create(cmd)), HTTPStatus.created);
    }
    catch (Exception e) {
      res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), HTTPStatus.badRequest);
    }
  }

  void lockModel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI, "planning");
    auto result = useCases.lock(id);
    if (result.isNull) {
      res.writeJsonBody(errorJson("Not found", 404), HTTPStatus.notFound);
      return;
    }
    res.writeJsonBody(toJsonValue(result));
  }

  void approveModel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI, "planning");
    auto result = useCases.approve(id);
    if (result.isNull) {
      res.writeJsonBody(errorJson("Not found", 404), HTTPStatus.notFound);
      return;
    }
    res.writeJsonBody(toJsonValue(result));
  }

  void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI, "planning");
    useCases.remove(id);
    res.writeJsonBody(Json.emptyObject, HTTPStatus.noContent);
  }
}
