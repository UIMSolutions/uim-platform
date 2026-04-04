/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.domain.ports.repositories.deployments;

import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation.domain.entities.model_deployment;

interface DeploymentRepository {
  ModelDeployment[] findByTenant(TenantId tenantId);
  ModelDeployment* findById(DeploymentId id, TenantId tenantId);
  ModelDeployment[] findByModelConfig(ModelConfigId configId, TenantId tenantId);
  ModelDeployment[] findByStatus(TenantId tenantId, DeploymentStatus status);
  ModelDeployment* findByTrainingJob(TrainingJobId jobId, TenantId tenantId);
  void save(ModelDeployment deployment);
  void update(ModelDeployment deployment);
  void remove(DeploymentId id, TenantId tenantId);
}
