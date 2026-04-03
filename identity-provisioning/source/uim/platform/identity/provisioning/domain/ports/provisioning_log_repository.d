module uim.platform.xyz.domain.ports.provisioning_log_repository;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.provisioning_log;

interface ProvisioningLogRepository
{
  ProvisioningLog[] findByTenant(TenantId tenantId);
  ProvisioningLog* findById(ProvisioningLogId id, TenantId tenantId);
  ProvisioningLog[] findByJob(ProvisioningJobId jobId, TenantId tenantId);
  ProvisioningLog[] findByEntity(string entityId, TenantId tenantId);
  ProvisioningLog[] findByStatus(TenantId tenantId, LogStatus status);
  long countByJob(ProvisioningJobId jobId, TenantId tenantId);
  long countByJobAndStatus(ProvisioningJobId jobId, TenantId tenantId, LogStatus status);
  void save(ProvisioningLog entity);
  void remove(ProvisioningLogId id, TenantId tenantId);
  void removeByJob(ProvisioningJobId jobId, TenantId tenantId);
}
