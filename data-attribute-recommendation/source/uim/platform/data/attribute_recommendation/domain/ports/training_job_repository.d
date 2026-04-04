/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.ports.repositories.training_jobs;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.training_job;

interface TrainingJobRepository
{
  TrainingJob[] findByTenant(TenantId tenantId);
  TrainingJob* findById(TrainingJobId id, TenantId tenantId);
  TrainingJob[] findByModelConfig(ModelConfigId configId, TenantId tenantId);
  TrainingJob[] findByStatus(TenantId tenantId, JobStatus status);
  void save(TrainingJob job);
  void update(TrainingJob job);
  void remove(TrainingJobId id, TenantId tenantId);
}
