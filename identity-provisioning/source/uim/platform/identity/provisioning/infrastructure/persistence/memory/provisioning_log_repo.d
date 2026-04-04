/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.infrastructure.persistence.memory.provisioning_log_repo;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.provisioning_log;
import uim.platform.identity.provisioning.domain.ports.repositories.provisioning_logs;

class MemoryProvisioningLogRepository : ProvisioningLogRepository {
  private ProvisioningLog[string] store;

  void save(ProvisioningLog entity)
  {
    store[entity.id] = entity;
  }

  void remove(ProvisioningLogId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  void removeByJob(ProvisioningJobId jobId, TenantId tenantId)
  {
    string[] toRemove;
    foreach (ref e; store)
      if (e.jobId == jobId && e.tenantId == tenantId)
        toRemove ~= e.id;
    foreach (id; toRemove)
      store.remove(id);
  }

  ProvisioningLog* findById(ProvisioningLogId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  ProvisioningLog[] findByTenant(TenantId tenantId)
  {
    ProvisioningLog[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProvisioningLog[] findByJob(ProvisioningJobId jobId, TenantId tenantId)
  {
    ProvisioningLog[] result;
    foreach (ref e; store)
      if (e.jobId == jobId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProvisioningLog[] findByEntity(string entityId, TenantId tenantId)
  {
    ProvisioningLog[] result;
    foreach (ref e; store)
      if (e.entityId == entityId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProvisioningLog[] findByStatus(TenantId tenantId, LogStatus status)
  {
    ProvisioningLog[] result;
    foreach (ref e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }

  long countByJob(ProvisioningJobId jobId, TenantId tenantId)
  {
    long count;
    foreach (ref e; store)
      if (e.jobId == jobId && e.tenantId == tenantId)
        count++;
    return count;
  }

  long countByJobAndStatus(ProvisioningJobId jobId, TenantId tenantId, LogStatus status)
  {
    long count;
    foreach (ref e; store)
      if (e.jobId == jobId && e.tenantId == tenantId && e.status == status)
        count++;
    return count;
  }
}
