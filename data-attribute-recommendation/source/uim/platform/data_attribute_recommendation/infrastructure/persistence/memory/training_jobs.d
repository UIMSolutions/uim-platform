/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.infrastructure.persistence.memory.training_jobs;


// import uim.platform.data_attribute_recommendation.domain.entities.training_job;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.training_jobs;
import uim.platform.data_attribute_recommendation;

// mixin(ShowModule!());

@safe:
class MemoryTrainingJobRepository : TenantRepository!(TrainingJob, TrainingJobId), TrainingJobRepository {
  
  size_t countByModelConfig(TenantId tenantId, ModelConfigurationId configId) {
    return findByModelConfig(tenantId, configId).length;
  }

  TrainingJob[] filterByModelConfig(TrainingJob[] jobs, ModelConfigurationId configId) {
    return jobs.filter!(e => e.modelConfigId == configId).array;
  }

  TrainingJob[] findByModelConfig(TenantId tenantId, ModelConfigurationId configId) {
    return filterByModelConfig(find(tenantId), configId);
  }

  void removeByModelConfig(TenantId tenantId, ModelConfigurationId configId) {
    findByModelConfig(tenantId, configId).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, JobStatus status) {
    return findByStatus(tenantId, status).length;
  }

  TrainingJob[] filterByStatus(TrainingJob[] jobs, JobStatus status) {
    return jobs.filter!(e => e.status == status).array;
  }
  
  TrainingJob[] findByStatus(TenantId tenantId, JobStatus status) {
    return filterByStatus(find(tenantId), status);
  }
  
  void removeByStatus(TenantId tenantId, JobStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }
}
