module domain.ports.deployment_repository;

import domain.types;
import domain.entities.model_deployment;

interface DeploymentRepository
{
  ModelDeployment[] findByTenant(TenantId tenantId);
  ModelDeployment* findById(DeploymentId id, TenantId tenantId);
  ModelDeployment[] findByModelConfig(ModelConfigId configId, TenantId tenantId);
  ModelDeployment[] findByStatus(TenantId tenantId, DeploymentStatus status);
  ModelDeployment* findByTrainingJob(TrainingJobId jobId, TenantId tenantId);
  void save(ModelDeployment deployment);
  void update(ModelDeployment deployment);
  void remove(DeploymentId id, TenantId tenantId);
}
