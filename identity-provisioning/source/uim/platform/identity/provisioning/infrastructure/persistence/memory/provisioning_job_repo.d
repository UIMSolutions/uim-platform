/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.infrastructure.persistence.memory.provisioning_job;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.provisioning_job;
import uim.platform.identity.provisioning.domain.ports.repositories.provisioning_jobs;

class MemoryProvisioningJobRepository : ProvisioningJobRepository {
  private ProvisioningJob[string] store;

  void save(ProvisioningJob entity) {
    store[entity.id] = entity;
  }

  void update(ProvisioningJob entity) {
    store[entity.id] = entity;
  }

  void remove(ProvisioningJobId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  ProvisioningJob* findById(ProvisioningJobId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  ProvisioningJob[] findByTenant(TenantId tenantId) {
    ProvisioningJob[] result;
    foreach (e; store)
      if (e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProvisioningJob[] findBySource(SourceSystemId sourcetenantId, id tenantId) {
    ProvisioningJob[] result;
    foreach (e; store)
      if (e.sourceSystemId == sourceId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProvisioningJob[] findByTarget(TargetSystemId targettenantId, id tenantId) {
    ProvisioningJob[] result;
    foreach (e; store)
      if (e.targetSystemId == targetId && e.tenantId == tenantId)
        result ~= e;
    return result;
  }

  ProvisioningJob[] findByStatus(TenantId tenantId, JobStatus status) {
    ProvisioningJob[] result;
    foreach (e; store)
      if (e.tenantId == tenantId && e.status == status)
        result ~= e;
    return result;
  }
}
