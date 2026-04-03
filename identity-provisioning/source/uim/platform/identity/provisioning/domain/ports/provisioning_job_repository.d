module uim.platform.xyz.domain.ports.provisioning_job_repository;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.provisioning_job;

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
