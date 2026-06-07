/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.entities.prediction;

import uim.platform.analytics;

// mixin(ShowModule!());
@safe:
/// A Prediction encapsulates a predictive/ML model run (SAC Smart Predict).
struct Prediction {
  mixin TenantEntity!(PredictionId);
  ResourceGroupId resourceGroupId;

  string name;
  string description;
  DatasetId datasetId;
  PredictionType predictionType;
  PredictionConfig config;
  PredictionResult lastResult;
  PredictionStatus predStatus;
  AuditInfo audit;

  // this() {
  // }

  static Prediction create(string name, string description, DatasetId datasetId,
      PredictionType predType, PredictionConfig cfg, UserId userId) {
    Prediction p;
    p.id = PredictionId(EntityId.generate().value);
    p.name = name;
    p.description = description;
    p.datasetId = datasetId;
    p.predictionType = predType;
    p.config = cfg;
    p.predStatus = PredictionStatus.Created;
    return p;
  }

  void markTraining() {
    predStatus = PredictionStatus.Training;
  }

  void markReady(PredictionResult result) {
    predStatus = PredictionStatus.Ready;
    lastResult = result;
  }

  void markFailed(string error) {
    predStatus = PredictionStatus.Failed;
    lastResult.errorMessage = error;
  }

  Json toJson() const {
      .set("name", name)
      .set("description", description)
      .set("datasetId", datasetId.value)
      .set("predictionType", predictionType.toString)
      .set("config", config.toJson())
      .set("lastResult", lastResult.toJson())
      .set("predStatus", predStatus.toString())
      .set("audit", audit.toJson());
  }
}

struct PredictionConfig {
  string targetColumn;
  string[] featureColumns;
  int horizonPeriods = 12;
  double trainTestSplit = 0.8;

  Json toJson() const {
    return Json.emptyObject
      .set("targetColumn", targetColumn)
      .set("featureColumns", featureColumns)
      .set("horizonPeriods", horizonPeriods)
      .set("trainTestSplit", trainTestSplit);
  }
}

struct PredictionResult {
  double accuracy = 0.0;
  double rmse = 0.0;
  double confidenceLevel = 0.0;
  string errorMessage;
  string modelSummary;

  Json toJson() const {
    return Json.emptyObject
      .set("accuracy", accuracy)
      .set("rmse", rmse)
      .set("confidenceLevel", confidenceLevel)
      .set("errorMessage", errorMessage)
      .set("modelSummary", modelSummary);
  }
}