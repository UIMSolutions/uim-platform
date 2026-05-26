/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.web.handlers.prediction;

// import uim.platform.analytics.app.usecases.predictions;
// import uim.platform.analytics.app.dto.prediction;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
class PredictionHandler {
  private PredictionUseCases useCases;

  this(PredictionUseCases useCases) {
    this.useCases = useCases;
  }

  void getAll(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto items = useCases.listPredictions();
    Json jArr = Json.emptyArray;
    foreach (item; items) jArr ~= toJsonValue(item);
    res.writeJsonBody(jArr);
  }

  void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = precheck.id;
    if (id.length == 0) {
      res.writeJsonBody(errorJson("Missing id"), 400);
      return;
    }
    auto item = useCases.getPrediction(id);
    if (item.predictionId.isEmpty) {
      res.writeJsonBody(errorJson("Not found", 404), 404);
      return;
    }
    res.writeJsonBody(toJsonValue(item));
  }

  void create(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto json = req.json;
      string[] features = getStrings(json, "featureColumns");
      auto cmd = CreatePredictionRequest(TenantId.init, ResourceGroupId.init,
          json["name"].get!string, json["description"].get!string,
          DatasetId(json["datasetId"].get!string), json["predictionType"].get!string,
          json["targetColumn"].get!string, features,
          UserId(json["userId"].get!string));
      res.writeJsonBody(toJsonValue(useCases.createPrediction(cmd)), 201);
    }
    catch (Exception e) {
      res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), 400);
    }
  }

  void train(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = precheck.id;
    auto result = useCases.trainPrediction(id);
    if (result.predictionId.isEmpty) {
      res.writeJsonBody(errorJson("Not found", 404), 404);
      return;
    }
    res.writeJsonBody(toJsonValue(result));
  }

  void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = precheck.id;
    useCases.deletePrediction(id);
    res.writeJsonBody(Json.emptyObject, 204);
  }
}
