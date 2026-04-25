/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.infrastructure.persistence.memory.deployments;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.model_deployment;
import uim.platform.data.attribute_recommendation.domain.ports.repositories.deployments;

class MemoryDeploymentRepository : TenantRepository!(ModelDeployment, DeploymentId), DeploymentRepository {

  bool existsByTrainingJob(TenantId tenantId, TrainingJobId jobId) {
    return findByTenant(tenantId).any!(e => e.trainingJobId == jobId);
  }

  ModelDeployment findByTrainingJob(TenantId tenantId, TrainingJobId jobId) {
    foreach (e; findByTenant(tenantId))
      if (e.trainingJobId == jobId)
        return e;
    return ModelDeployment.init;
  }

  size_t countByModelConfig(TenantId tenantId, ModelConfigId configId) {
    return findByModelConfig(tenantId, configId).length;
  }

  ModelDeployment[] filterByModelConfig(ModelDeployment[] deployments, ModelConfigId configId) {
    return deployments.filter!(e => e.modelConfigId == configId).array;
  }

  ModelDeployment[] findByModelConfig(TenantId tenantId, ModelConfigId configId) {
    return findByTenant(tenantId).filterByModelConfig!(configId);
  }

  void removeByModelConfig(TenantId tenantId, ModelConfigId configId) {
    findByModelConfig(tenantId, configId).removeAll;
  }

  size_t countByStatus(TenantId tenantId, DeploymentStatus status) {
    return findByStatus(tenantId, status).length;
  }

  ModelDeployment[] filterByStatus(ModelDeployment[] deployments, DeploymentStatus status) {
    return deployments.filter!(e => e.status == status).array;
  }

  ModelDeployment[] findByStatus(TenantId tenantId, DeploymentStatus status) {
    return findByTenant(tenantId).filterByStatus!(status);
  }

  void removeByStatus(TenantId tenantId, DeploymentStatus status) {
    findByStatus(tenantId, status).removeAll;
  }

}
