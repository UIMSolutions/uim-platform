/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.infrastructure.persistence
  .memory.training_job_repo;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.training_job;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.training_jobs;

class MemoryTrainingJobRepository : TrainingJobRepository
{
  private TrainingJob[string] store;

  void save(TrainingJob entity)
  {
    store[entity.id] = entity;
  }

  void update(TrainingJob entity)
  {
    store[entity.id] = entity;
  }

  void remove(TrainingJobId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  TrainingJob* findById(TrainingJobId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  TrainingJob[] findByTenant(TenantId tenantId)
  {
    TrainingJob[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  TrainingJob[] findByModelConfig(ModelConfigId configId, TenantId tenantId)
  {
    TrainingJob[] result;
    foreach (ref e; store)
      if (e.modelConfigId == configId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  TrainingJob[] findByStatus(TenantId tenantId, JobStatus status)
  {
    TrainingJob[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }
}
