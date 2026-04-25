/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.ports.repositories.deployments;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.model_deployment;

interface DeploymentRepository : ITenantRepository!(ModelDeployment, DeploymentId) {

  bool existsByTrainingJob(TenantId tenantId, TrainingJobId jobId);
  ModelDeployment findByTrainingJob(TenantId tenantId, TrainingJobId jobId);
  void removeByTrainingJob(TenantId tenantId, TrainingJobId jobId);

  size_t countByModelConfig(TenantId tenantId, ModelConfigId configId);
  ModelDeployment[] filterByModelConfig(ModelDeployment[] deployments, ModelConfigId configId);
  ModelDeployment[] findByModelConfig(TenantId tenantId, ModelConfigId configId);
  void removeByModelConfig(TenantId tenantId, ModelConfigId configId);

  size_t countByStatus(TenantId tenantId, DeploymentStatus status);
  ModelDeployment[] filterByStatus(ModelDeployment[] deployments, DeploymentStatus status);
  ModelDeployment[] findByStatus(TenantId tenantId, DeploymentStatus status);
  void removeByStatus(TenantId tenantId, DeploymentStatus status);

}
