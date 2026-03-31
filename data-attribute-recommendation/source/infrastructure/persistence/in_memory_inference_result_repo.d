module infrastructure.persistence.in_memory_inference_result_repo;

import domain.types;
import domain.entities.inference_result;
import domain.ports.inference_result_repository;

class InMemoryInferenceResultRepository : InferenceResultRepository
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
