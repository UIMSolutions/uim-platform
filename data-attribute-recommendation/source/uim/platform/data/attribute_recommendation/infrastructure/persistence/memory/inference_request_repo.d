/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.infrastructure.persistence.memory.inference_requests;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.inference_request;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.inference_requests;

class MemoryInferenceRequestRepository : InferenceRequestRepository {
  private InferenceRequest[string] store;

  void save(InferenceRequest entity) {
    store[entity.id] = entity;
  }

  void update(InferenceRequest entity) {
    store[entity.id] = entity;
  }

  void remove(InferenceRequestId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  InferenceRequest* findById(InferenceRequestId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  InferenceRequest[] findByTenant(TenantId tenantId) {
    InferenceRequest[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  InferenceRequest[] findByDeployment(DeploymentId deploymenttenantId, id tenantId) {
    InferenceRequest[] result;
    foreach (ref e; store)
      if (e.deploymentId == deploymentId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  InferenceRequest[] findByStatus(TenantId tenantId, InferenceStatus status) {
    InferenceRequest[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }
}
