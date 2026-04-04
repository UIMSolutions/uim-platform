/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.repositories.provisioning_logs;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.provisioning_log;

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
