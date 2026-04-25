/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.infrastructure.persistence.memory.training_jobs;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.training_job;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.training_jobs;

class MemoryTrainingJobRepository : TenantRepository!(TrainingJob, TrainingJobId), TrainingJobRepository {
  
  size_t countByModelConfig(TenantId tenantId, ModelConfigId configId) {
    return findByModelConfig(tenantId, configId).length;
  }

  TrainingJob[] filterByModelConfig(TrainingJob[] jobs, ModelConfigId configId) {
    return jobs.filter!(e => e.modelConfigId == configId).array;
  }

  TrainingJob[] findByModelConfig(TenantId tenantId, ModelConfigId configId) {
    return findByTenant(tenantId).filterByModelConfig!(configId);
  }

  void removeByModelConfig(TenantId tenantId, ModelConfigId configId) {
    findByModelConfig(tenantId, configId).removeAll;
  }

  size_t countByStatus(TenantId tenantId, JobStatus status) {
    return findByStatus(tenantId, status).length;
  }

  TrainingJob[] filterByStatus(TrainingJob[] jobs, JobStatus status) {
    return jobs.filter!(e => e.status == status).array;
  }
  
  TrainingJob[] findByStatus(TenantId tenantId, JobStatus status) {
    return findByTenant(tenantId).filterByStatus!(status);
  }
  
  void removeByStatus(TenantId tenantId, JobStatus status) {
    findByStatus(tenantId, status).removeAll;
  }
}
