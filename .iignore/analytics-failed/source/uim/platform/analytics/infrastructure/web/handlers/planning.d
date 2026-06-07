/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.web.handlers.planning;

// import uim.platform.analytics.app.usecases.planning;
// import uim.platform.analytics.app.dto.planning;

import uim.platform.analytics;

// mixin(ShowModule!());
@safe:
class PlanningHandler {
  private PlanningUseCases useCases;

  this(PlanningUseCases useCases) {
    this.useCases = useCases;
  }

  void getAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto items = useCases.listPlanningModels(TenantId.init);
    Json jArr = Json.emptyArray;
    foreach (item; items) jArr ~= toJsonValue(item);
    res.writeJsonBody(jArr);
  }

  void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = PlanningModelId(precheck.id);
    if (id.isNull) {
      res.writeJsonBody(errorJson("Missing planning model id"), 400);
      return;
    }
    auto item = useCases.getById(id);
    if (item.planningModelId.isEmpty) {
      res.writeJsonBody(errorJson("Planning model not found", 404), 404);
      return;
    }
    res.writeJsonBody(toJsonValue(item));
  }

  void create(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto json = req.json;
      auto cmd = CreatePlanningModelRequest(TenantId.init,
          json["name"].get!string, json["description"].get!string,
          json["datasetId"].get!string, json["granularity"].get!string,
          UserId(json["userId"].get!string));
      res.writeJsonBody(toJsonValue(useCases.createPlanningModel(cmd)), 201);
    }
    catch (Exception e) {
      res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), 400);
    }
  }

  void lockModel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = PlanningModelId(precheck.id);
    if (id.isNull) {
      res.writeJsonBody(errorJson("Missing planning model id"), 400);
      return;
    }
    auto result = useCases.lockPlanningModel(TenantId.init, id);
    if (result.planningModelId.isEmpty) {
      res.writeJsonBody(errorJson("Planning model not found", 404), 404);
      return;
    }
    res.writeJsonBody(toJsonValue(result));
  }

  void approveModel(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = PlanningModelId(precheck.id);
    if (id.isNull) {
      res.writeJsonBody(errorJson("Missing planning model id"), 400);
      return;
    }
    auto result = useCases.approvePlanningModel(TenantId.init, id);
    if (result.planningModelId.isEmpty) {
      res.writeJsonBody(errorJson("Planning model not found", 404), 404);
      return;
    }
    res.writeJsonBody(toJsonValue(result));
  }

  void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = PlanningModelId(precheck.id);
    if (id.isNull) {
      res.writeJsonBody(errorJson("Missing planning model id"), 400);
      return;
    }
    useCases.deletePlanningModel(TenantId.init, id);
    res.writeJsonBody(Json.emptyObject, 204);
  }
}
