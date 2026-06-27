/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.domain.ports.deployments;


// import uim.platform.data_attribute_recommendation.domain.entities.model_deployment;
import uim.platform.data_attribute_recommendation;

// mixin(ShowModule!());

@safe:
interface DeploymentRepository : ITentRepository!(ModelDeployment, DeploymentId) {

  bool existsByTrainingJob(TenantId tenantId, TrainingJobId jobId);
  ModelDeployment findByTrainingJob(TenantId tenantId, TrainingJobId jobId);
  void removeByTrainingJob(TenantId tenantId, TrainingJobId jobId);

  size_t countByModelConfig(TenantId tenantId, ModelConfigurationId configId);
  ModelDeployment[] findByModelConfig(TenantId tenantId, ModelConfigurationId configId);
  void removeByModelConfig(TenantId tenantId, ModelConfigurationId configId);

  size_t countByStatus(TenantId tenantId, DeploymentStatus status);
  ModelDeployment[] findByStatus(TenantId tenantId, DeploymentStatus status);
  void removeByStatus(TenantId tenantId, DeploymentStatus status);

}
