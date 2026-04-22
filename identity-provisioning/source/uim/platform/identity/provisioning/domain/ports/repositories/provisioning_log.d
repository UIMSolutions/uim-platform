/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.domain.ports.repositories.provisioning_logs;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.provisioning_log;

interface ProvisioningLogRepository : ITenantRepository!(ProvisioningLog, ProvisioningLogId) {

  size_t countByJob(TenantId tenantId, ProvisioningJobId jobId);
  ProvisioningLog[] findByJob(TenantId tenantId, ProvisioningJobId jobId);
  void removeByJob(TenantId tenantId, ProvisioningJobId jobId);

  size_t countByEntity(TenantId tenantId, string entityId);
  ProvisioningLog[] findByEntity(TenantId tenantId, string entityId);
  void removeByEntity(TenantId tenantId, string entityId);

  size_t countByStatus(TenantId tenantId, LogStatus status);
  ProvisioningLog[] findByStatus(TenantId tenantId, LogStatus status);
  void removeByStatus(TenantId tenantId, LogStatus status);
  
  size_t countByJobAndStatus(TenantId tenantId, ProvisioningJobId jobId, LogStatus status);
}
