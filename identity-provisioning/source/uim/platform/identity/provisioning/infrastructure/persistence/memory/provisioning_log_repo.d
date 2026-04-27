/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.infrastructure.persistence.memory.provisioning_log;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.provisioning_log;
import uim.platform.identity.provisioning.domain.ports.repositories.provisioning_logs;

class MemoryProvisioningLogRepository : TenantRepository!(ProvisioningLog, ProvisioningLogId), ProvisioningLogRepository {

  ProvisioningLog[] findByTenant(TenantId tenantId) {
    ProvisioningLog[] result;
    foreach (e; findAll)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  size_t countByJob(TenantId tenantId, ProvisioningJobId jobId) {
    return findByJob(tenantId, jobId).length;
  }
  ProvisioningLog[] filterByJob(ProvisioningLog[] logs, ProvisioningJobId jobId) {
    return logs.filter!(e => e.jobId == jobId).array;
  }
  ProvisioningLog[] findByJob(TenantId tenantId, ProvisioningJobId jobId) {
    return filterByJob(findByTenant(tenantId), jobId);
  }
  void removeByJob(TenantId tenantId, ProvisioningJobId jobId) {
    findByJob(tenantId, jobId).each!(e => remove(e));
  }

  size_t countByEntity(TenantId tenantId, string entityId) {
    return findByEntity(tenantId, entityId).length;
  }
  ProvisioningLog[] filterByEntity(ProvisioningLog[] logs, string entityId) {
    return logs.filter!(e => e.entityId == entityId).array;
  }
  ProvisioningLog[] findByEntity(TenantId tenantId, string entityId) {
    return filterByEntity(findByTenant(tenantId), entityId);
  }
  void removeByEntity(TenantId tenantId, string entityId) {
    findByEntity(tenantId, entityId).each!(e => remove(e)); 
  }

  size_t countByStatus(TenantId tenantId, LogStatus status) {
    return findByStatus(tenantId, status).length;
  }
  ProvisioningLog[] filterByStatus(ProvisioningLog[] logs, LogStatus status) {
    return logs.filter!(e => e.status == status).array;
  }
  ProvisioningLog[] findByStatus(TenantId tenantId, LogStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }
  void removeByStatus(TenantId tenantId, LogStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }

  size_t countByJobAndStatus(TenantId tenantId, ProvisioningJobId jobId, LogStatus status) {
    return filterByStatus(findByJob(tenantId, jobId), status).length;
  }
}
