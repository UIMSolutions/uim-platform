module uim.platform.data.attribute_recommendation.infrastructure.persistence
  .memory.inference_result_repo;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.inference_result;
import uim.platform.data.attribute_recommendation.domain.ports.inference_result_repository;

class MemoryInferenceResultRepository : InferenceResultRepository
{
  private InferenceResult[string] store;

  void save(InferenceResult entity)
  {
    store[entity.id] = entity;
  }

  void update(InferenceResult entity)
  {
    store[entity.id] = entity;
  }

  void remove(InferenceResultId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  InferenceResult* findById(InferenceResultId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  InferenceResult* findByRequest(InferenceRequestId requestId, TenantId tenantId)
  {
    foreach (ref e; store)
      if (e.requestId == requestId && e.tenantId == tenantId)
        return &e;
    return null;
  }

  InferenceResult[] findByTenant(TenantId tenantId)
  {
    InferenceResult[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }
}
