/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.infrastructure.persistence.memory.deployments;


// import uim.platform.data_attribute_recommendation.domain.entities.model_deployment;
// import uim.platform.data_attribute_recommendation.domain.ports.repositories.deployments;
import uim.platform.data_attribute_recommendation;

// mixin(ShowModule!());

@safe:
class MemoryDeploymentRepository : TenantRepository!(ModelDeployment, DeploymentId), DeploymentRepository {

  bool existsByTrainingJob(TenantId tenantId, TrainingJobId jobId) {
    return find(tenantId).any!(e => e.trainingJobId == jobId);
  }

  ModelDeployment findByTrainingJob(TenantId tenantId, TrainingJobId jobId) {
    foreach (e; find(tenantId))
      if (e.trainingJobId == jobId)
        return e;
    return ModelDeployment.init;
  }

  void removeByTrainingJob(TenantId tenantId, TrainingJobId jobId) {
    remove(findByTrainingJob(tenantId, jobId));
  }

  size_t countByModelConfig(TenantId tenantId, ModelConfigurationId configId) {
    return findByModelConfig(tenantId, configId).length;
  }

  ModelDeployment[] filterByModelConfig(ModelDeployment[] deployments, ModelConfigurationId configId) {
    return deployments.filter!(e => e.modelConfigId == configId).array;
  }

  ModelDeployment[] findByModelConfig(TenantId tenantId, ModelConfigurationId configId) {
    return filterByModelConfig(find(tenantId), configId);
  }

  void removeByModelConfig(TenantId tenantId, ModelConfigurationId configId) {
    findByModelConfig(tenantId, configId).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, DeploymentStatus status) {
    return findByStatus(tenantId, status).length;
  }

  ModelDeployment[] filterByStatus(ModelDeployment[] deployments, DeploymentStatus status) {
    return deployments.filter!(e => e.status == status).array;
  }

  ModelDeployment[] findByStatus(TenantId tenantId, DeploymentStatus status) {
    return filterByStatus(find(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, DeploymentStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }

}
