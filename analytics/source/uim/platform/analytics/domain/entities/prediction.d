/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.entities.prediction;
// import uim.platform.analytics.domain.values.common;
import uim.platform.analytics;

mixin(ShowModule!());
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
}

