module uim.platform.data_attribute_recommendation.infrastructure.persistence.memory.inference_request_repo;

import domain.types;
import domain.entities.inference_request;
import domain.ports.inference_request_repository;

class MemoryInferenceRequestRepository : InferenceRequestRepository
{
  private InferenceRequest[string] store;

  void save(InferenceRequest entity)
  {
    store[entity.id] = entity;
  }

  void update(InferenceRequest entity)
  {
    store[entity.id] = entity;
  }

  void remove(InferenceRequestId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  InferenceRequest* findById(InferenceRequestId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  InferenceRequest[] findByTenant(TenantId tenantId)
  {
    InferenceRequest[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  InferenceRequest[] findByDeployment(DeploymentId deploymentId, TenantId tenantId)
  {
    InferenceRequest[] result;
    foreach (ref e; store)
      if (e.deploymentId == deploymentId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  InferenceRequest[] findByStatus(TenantId tenantId, InferenceStatus status)
  {
    InferenceRequest[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }
}
