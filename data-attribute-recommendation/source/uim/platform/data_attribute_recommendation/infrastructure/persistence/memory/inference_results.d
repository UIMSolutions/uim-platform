/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.infrastructure.persistence
  .memory.inference_results;


// import uim.platform.data_attribute_recommendation.domain.entities.inference_result;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.inference_results;
import uim.platform.data_attribute_recommendation;

// mixin(ShowModule!());

@safe:
class MemoryInferenceResultRepository : TenantRepository!(InferenceResult, InferenceResultId), InferenceResultRepository {

  bool existsByRequest(TenantId tenantId, InferenceRequestId requestId) {
    foreach (e; findByTenant(tenantId))
      if (e.requestId == requestId && e.tenantId == tenantId)
        return true;
    return false;
  }

  InferenceResult findByRequest(TenantId tenantId, InferenceRequestId requestId) {
    foreach (e; findByTenant(tenantId))
      if (e.requestId == requestId && e.tenantId == tenantId)
        return e;
    return InferenceResult.init;
  }

  void removeByRequest(TenantId tenantId, InferenceRequestId requestId) {
    remove(findByRequest(tenantId, requestId));
  }

  size_t countByPredictions(TenantId tenantId, string predictions) {
    return findByPredictions(tenantId, predictions).length;
  }

  InferenceResult[] filterByPredictions(InferenceResult[] results, string predictions) {
    return results.filter!(e => e.predictions == predictions).array;
  }

  InferenceResult[] findByPredictions(TenantId tenantId, string predictions) {
    return filterByPredictions(findByTenant(tenantId), predictions);
  }

  void removeByPredictions(TenantId tenantId, string predictions) {
    findByPredictions(tenantId, predictions).each!(e => remove(e));
  }

}
