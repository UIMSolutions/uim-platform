module uim.platform.data.attribute_recommendation.domain.ports.training_job_repository;

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
