/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.infrastructure.persistence.memory.replication_job;

import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.domain.entities.replication_job;
import uim.platform.master_data_integration.domain.ports.repositories.replication_jobs;

// import std.algorithm : filter;
// import std.array : array;

class MemoryReplicationJobRepository : TenantRepository!(ReplicationJob, ReplicationJobId), ReplicationJobRepository {


  size_t countByStatus(TenantId tenantId, ReplicationJobStatus status) {
    return findByStatus(tenantId, status).length;
  }
  ReplicationJob[] filterByStatus(ReplicationJob[] jobs, ReplicationJobStatus status) {
    return jobs.filter!(e => e.status == status).array;
  }
  ReplicationJob[] findByStatus(TenantId tenantId, ReplicationJobStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }
  void removeByStatus(TenantId tenantId, ReplicationJobStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e));
  }

  size_t countByDistributionModel(TenantId tenantId, DistributionModelId modelId) {
    return findByDistributionModel(tenantId, modelId).length;
  }
  ReplicationJob[] filterByDistributionModel(ReplicationJob[] jobs, DistributionModelId modelId) {
    return jobs.filter!(e => e.distributionModelId == modelId).array;
  }
  ReplicationJob[] findByDistributionModel(TenantId tenantId, DistributionModelId modelId) {
    return filterByDistributionModel(findByTenant(tenantId), modelId);
  }
  void removeByDistributionModel(TenantId tenantId, DistributionModelId modelId) {
    findByDistributionModel(tenantId, modelId).each!(e => remove(e));
  }

}
