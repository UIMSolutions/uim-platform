/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.web.handlers.prediction;

// import vibe.http.server;
// import vibe.data.json;
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
    res.writeJsonBody(useCases.list().toJson);
  }

  void getOne(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI, "predictions");
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
      string[] features;
      if ("featureColumns" in json) {
        features = json["featureColumns"].toArray.map!(f => f.get!string).array;
      }
      auto cmd = CreatePredictionRequest(json.getString("name"), json.getString("description"),
          json.getString("datasetId"), json.getString("predictionType"),
          json.getString("targetColumn"), features, json.getString("userId"));
      res.writeJsonBody(toJsonValue(useCases.create(cmd)), HTTPStatus.created);
    }
    catch (Exception e) {
      res.writeJsonBody(errorJson("Invalid request: " ~ e.msg), HTTPStatus.badRequest);
    }
  }

  void train(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI, "predictions");
    auto result = useCases.train(id);
    if (result.isNull) {
      res.writeJsonBody(errorJson("Not found", 404), HTTPStatus.notFound);
      return;
    }
    res.writeJsonBody(toJsonValue(result));
  }

  void remove(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto id = extractIdFromPath(req.requestURI, "predictions");
    useCases.removeById(id);
    res.writeJsonBody(Json.emptyObject, HTTPStatus.noContent);
  }
}
