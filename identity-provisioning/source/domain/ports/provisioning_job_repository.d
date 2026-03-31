module domain.ports.provisioning_job_repository;

import domain.types;
import domain.entities.provisioning_job;

interface ProvisioningJobRepository
{
  ProvisioningJob[] findByTenant(TenantId tenantId);
  ProvisioningJob* findById(ProvisioningJobId id, TenantId tenantId);
  ProvisioningJob[] findBySource(SourceSystemId sourceId, TenantId tenantId);
  ProvisioningJob[] findByTarget(TargetSystemId targetId, TenantId tenantId);
  ProvisioningJob[] findByStatus(TenantId tenantId, JobStatus status);
  void save(ProvisioningJob entity);
  void update(ProvisioningJob entity);
  void remove(ProvisioningJobId id, TenantId tenantId);
}
