/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.infrastructure.persistence.memory.provisioning_log;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.provisioning_log;
import uim.platform.identity.provisioning.domain.ports.repositories.provisioning_logs;

class MemoryProvisioningLogRepository : ProvisioningLogRepository {
  private ProvisioningLog[string] store;

  void save(ProvisioningLog entity) {
    store[entity.id] = entity;
  }

  void remove(ProvisioningLogId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  void removeByJob(ProvisioningJobId jobtenantId, id tenantId) {
    string[] toRemove;
    foreach (e; findAll)
      if (e.jobId == jobId && e.tenantId == tenantId)
        toRemove ~= e.id;
    foreach (id; toRemove)
      store.remove(id);
  }

  ProvisioningLog* findById(ProvisioningLogId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  ProvisioningLog[] findByTenant(TenantId tenantId) {
    ProvisioningLog[] result;
    foreach (e; findAll)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProvisioningLog[] findByJob(ProvisioningJobId jobtenantId, id tenantId) {
    ProvisioningLog[] result;
    foreach (e; findAll)
      if (e.jobId == jobId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProvisioningLog[] findByEntity(string entitytenantId, id tenantId) {
    ProvisioningLog[] result;
    foreach (e; findAll)
      if (e.entityId == entityId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProvisioningLog[] findByStatus(TenantId tenantId, LogStatus status) {
    ProvisioningLog[] result;
    foreach (e; findByTenant(tenantId))
      if (e.status == status)
        result ~= e;
    return result;
  }

  size_t countByJob(ProvisioningJobId jobtenantId, id tenantId) {
    size_t count;
    foreach (e; findAll)
      if (e.jobId == jobId && e.tenantId == tenantId)
        count++;
    return count;
  }

  size_t countByJobAndStatus(ProvisioningJobId jobtenantId, id tenantId, LogStatus status) {
    size_t count;
    foreach (e; findAll)
      if (e.jobId == jobId && e.tenantId == tenantId && e.status == status)
        count++;
    return count;
  }
}
