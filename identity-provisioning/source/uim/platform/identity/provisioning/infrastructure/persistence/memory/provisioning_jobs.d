/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.infrastructure.persistence.memory.provisioning_job;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.provisioning_job;
import uim.platform.identity.provisioning.domain.ports.repositories.provisioning_jobs;

class MemoryProvisioningJobRepository : TenantRepository!(ProvisioningJob, ProvisioningJobId), ProvisioningJobRepository {

  size_t countBySource(TenantId tenantId, SourceSystemId sourceId) {
    return findBySource(tenantId, sourceId).length;
  }
  ProvisioningJob[] filterBySource(ProvisioningJob[] jobs, SourceSystemId sourceId) {
    return jobs.filter!(e => e.sourceSystemId == sourceId).array;
  }
  ProvisioningJob[] findBySource(TenantId tenantId, SourceSystemId sourceId) {
    return filterBySource(findVyTenant(tenantId), sourceId)
  }
  void removeBySource(TenantId tenantId, SourceSystemId sourceId) {
    findBySource(tenantId, sourceId).each!(e => remove(e));
  }

  size_t countByTarget(TenantId tenantId, TargetSystemId targetId) {
    return findByTarget(tenantId, targetId).length;
  }
  ProvisioningJob[] filterByTarget(ProvisioningJob[] jobs, TargetSystemId targetId) {
    return jobs.filter!(e => e.targetSystemId == targetId).array;
  }
  ProvisioningJob[] findByTarget(TenantId tenantId, TargetSystemId targetId) {
    return filterByTarget(findByTenant(tenantId), targetId);
  }
  void removeByTarget(TenantId tenantId, TargetSystemId targetId) {
    findByTarget(tenantId, targetId).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, EntityStatus status) {
    return findByStatus(tenantId, status).length;
  }
  ProvisioningJob[] filterByStatus(ProvisioningJob[] jobs, JobStatus status) {
    return jobs.filter!(e => e.status == status).array;
  }
  ProvisioningJob[] findByStatus(TenantId tenantId, JobStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }
  void removeByStatus(TenantId tenantId, JobStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }

}
