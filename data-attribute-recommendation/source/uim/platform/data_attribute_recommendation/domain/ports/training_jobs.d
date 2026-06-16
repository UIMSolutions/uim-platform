/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.domain.ports.training_jobs;

  
  // import uim.platform.data_attribute_recommendation.domain.entities.training_job;
import uim.platform.data_attribute_recommendation;

// mixin(ShowModule!());

@safe:
interface TrainingJobRepository : ITenantRepository!(TrainingJob, TrainingJobId) {

  size_t countByModelConfig(TenantId tenantId, ModelConfigurationId configId);
  TrainingJob[] findByModelConfig(TenantId tenantId, ModelConfigurationId configId);
  void removeByModelConfig(TenantId tenantId, ModelConfigurationId configId);
  
  size_t countByStatus(TenantId tenantId, JobStatus status);
  TrainingJob[] findByStatus(TenantId tenantId, JobStatus status);
  void removeByStatus(TenantId tenantId, JobStatus status);

}
