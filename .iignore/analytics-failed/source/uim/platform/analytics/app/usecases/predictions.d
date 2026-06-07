/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.app.usecases.predictions;
// import uim.platform.analytics.domain.entities.prediction;
// import uim.platform.analytics.domain.repositories.prediction;

// import uim.platform.analytics.app.dto.prediction;


import uim.platform.analytics;

// mixin(ShowModule!());
@safe:
class PredictionUseCases {
  private PredictionRepository repo;

  this(PredictionRepository repo) {
    this.repo = repo;
  }

  PredictionResponse createPrediction(CreatePredictionRequest req) {
    PredictionType pt;
    try {
      pt = req.predictionType.to!PredictionType;
    } catch (Exception) {
      pt = PredictionType.Regression;
    }
    auto cfg = PredictionConfig(req.targetColumn, req.featureColumns);
    auto p = Prediction.create(req.name, req.description, req.datasetId, pt, cfg, req.userId);
    repo.save(p);
    return PredictionResponse.fromEntity(p);
  }

  PredictionResponse getPrediction(TenantId tenantId, string id) {
    auto found = repo.findByTenant(tenantId).filter!(e => e.id.value == id).array;
    return PredictionResponse.fromEntity(found.empty ? Prediction.init : found[0]);
  }

  PredictionResponse[] listPredictions(TenantId tenantId) {
    PredictionResponse[] result;
    foreach (p; repo.findByTenant(tenantId))
      result ~= PredictionResponse.fromEntity(p);
    return result;
  }

  PredictionResponse trainPrediction(TenantId tenantId, string id) {
    auto found = repo.findByTenant(tenantId).filter!(e => e.id.value == id).array;
    auto p = found.empty ? Prediction.init : found[0];
    if (p.isNull)
      return PredictionResponse.init;
    p.markTraining();
    // Simulated training result
    p.markReady(PredictionResult(0.85, 12.5, 0.95, "", "Model trained successfully"));
    repo.save(p);
    return PredictionResponse.fromEntity(p);
  }

  CommandResult deletePrediction(TenantId tenantId, string id) {
    auto found = repo.findByTenant(tenantId).filter!(e => e.id.value == id).array;
    if (!found.empty) repo.remove(found[0]);
    return CommandResult(true, id, "");
  }
}
