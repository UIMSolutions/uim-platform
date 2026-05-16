/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.repositories.prediction;
// import uim.platform.analytics.domain.entities.prediction;
// import uim.platform.analytics.domain.values.common;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:

interface PredictionRepository : ITenantRepository!(Prediction, PredictionId) {
  
  size_t countByDataset(TenantId tenantId, EntityId datasetId);
  Prediction[] findByDataset(TenantId tenantId, EntityId datasetId);
  void removeByDataset(TenantId tenantId, EntityId datasetId);
}
