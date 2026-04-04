/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.infrastructure.persistence.memory.deployment_repo;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.model_deployment;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.deployments;

class MemoryDeploymentRepository : DeploymentRepository
{
  private ModelDeployment[string] store;

  void save(ModelDeployment entity)
  {
    store[entity.id] = entity;
  }

  void update(ModelDeployment entity)
  {
    store[entity.id] = entity;
  }

  void remove(DeploymentId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  ModelDeployment* findById(DeploymentId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  ModelDeployment[] findByTenant(TenantId tenantId)
  {
    ModelDeployment[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ModelDeployment[] findByModelConfig(ModelConfigId configId, TenantId tenantId)
  {
    ModelDeployment[] result;
    foreach (ref e; store)
      if (e.modelConfigId == configId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ModelDeployment[] findByStatus(TenantId tenantId, DeploymentStatus status)
  {
    ModelDeployment[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }

  ModelDeployment* findByTrainingJob(TrainingJobId jobId, TenantId tenantId)
  {
    foreach (ref e; store)
      if (e.trainingJobId == jobId && e.tenantId == tenantId)
        return &e;
    return null;
  }
}
