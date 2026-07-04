/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.persistence.memory.repositories.predictions;
// import uim.platform.analytics.domain.entities.prediction;
// import uim.platform.analytics.domain.repositories.prediction;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
class MemoryPredictionRepository : TenantRepository!(Prediction, PredictionId), PredictionRepository {

  size_t countByDataset(TenantId tenantId, EntityId datasetId) {
    return findByDataset(tenantId, datasetId).length;
  }

  Prediction[] findByDataset(TenantId tenantId, EntityId datasetId) {
    return findByTenant(tenantId).filter!(p => p.datasetId.value == datasetId.value).array;
  }

  void removeByDataset(TenantId tenantId, EntityId datasetId) {
    foreach (p; findByDataset(tenantId, datasetId))
      remove(p);
  }
}
