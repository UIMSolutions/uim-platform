/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.persistence.memory.repositories.prediction;
// import uim.platform.analytics.domain.entities.prediction;
// import uim.platform.analytics.domain.repositories.prediction;
import uim.platform.analytics.domain.values.common;

class MemoryPredictionRepository : TenantRepository!(Prediction, EntityId), PredictionRepository {
 
 

  Prediction[] findByDataset(EntityId datasetId) {
    Prediction[] result;
    foreach (p; findByTenant(tenantId))
      if (p.datasetId == datasetId)
        result ~= p;
    return result;
  }

  Prediction[] findByTenant(tenantId) {
    return store.values;
  }

  void save(Prediction prediction) {
    store[prediction.id.value] = prediction;
  }

  void remove(EntityId id) {
    store.remove(id.value);
  }
}
