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

class MemoryInferenceResultRepository : InferenceResultRepository {
  private InferenceResult[string] store;

  void save(InferenceResult entity) {
    store[entity.id] = entity;
  }

  void update(InferenceResult entity) {
    store[entity.id] = entity;
  }

  void remove(InferenceResultId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  InferenceResult* findById(InferenceResultId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  InferenceResult* findByRequest(InferenceRequestId requesttenantId, id tenantId) {
    foreach (ref e; store)
      if (e.requestId == requestId && e.tenantId == tenantId)
        return &e;
    return null;
  }

  InferenceResult[] findByTenant(TenantId tenantId) {
    InferenceResult[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }
}
