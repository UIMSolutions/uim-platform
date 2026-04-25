/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.infrastructure.persistence
  .memory.inference_result;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.inference_result;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.inference_results;

class MemoryInferenceResultRepository : TenantRepository!(InferenceResult, InferenceResultId), InferenceResultRepository {

  bool existsByRequest(TenantId tenantId, InferenceRequestId requestId) {
    foreach (e; findAll)
      if (e.requestId == requestId && e.tenantId == tenantId)
        return true;
    return false;
  }

  InferenceResult findByRequest(TenantId tenantId, InferenceRequestId requestId) {
    foreach (e; findAll)
      if (e.requestId == requestId && e.tenantId == tenantId)
        return e;
    return InferenceResult.init;
  }

  void removeByRequest(TenantId tenantId, InferenceRequestId requestId) {
    findByRequest(tenantId, requestId).remove;
  }
  
}
