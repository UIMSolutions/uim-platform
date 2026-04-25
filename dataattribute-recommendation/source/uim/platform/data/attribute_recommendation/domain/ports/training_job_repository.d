/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.ports.repositories.training_jobs;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.training_job;

interface TrainingJobRepository : ITenantRepository!(TrainingJob, TrainingJobId) {

  size_t countByModelConfig(TenantId tenantId, ModelConfigId configId);
  TrainingJob[] filterByModelConfig(TrainingJob[] jobs, ModelConfigId configId);
  TrainingJob[] findByModelConfig(TenantId tenantId, ModelConfigId configId);
  void removeByModelConfig(TenantId tenantId, ModelConfigId configId);
  
  size_t countByStatus(TenantId tenantId, JobStatus status);
  TrainingJob[] filterByStatus(TrainingJob[] jobs, JobStatus status);
  TrainingJob[] findByStatus(TenantId tenantId, JobStatus status);
  void removeByStatus(TenantId tenantId, JobStatus status);

}
