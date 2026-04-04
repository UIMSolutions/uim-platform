/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.infrastructure.persistence.memory.replication_job_repo;

import uim.platform.master_data_integration.domain.types;
import uim.platform.master_data_integration.domain.entities.replication_job;
import uim.platform.master_data_integration.domain.ports.repositories.replication_jobs;

// import std.algorithm : filter;
// import std.array : array;

class MemoryReplicationJobRepository : ReplicationJobRepository {
  private ReplicationJob[ReplicationJobId] store;

  ReplicationJob findById(ReplicationJobId id)
  {
    if (auto p = id in store)
      return *p;
    return ReplicationJob.init;
  }

  ReplicationJob[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  ReplicationJob[] findByStatus(TenantId tenantId, ReplicationJobStatus status)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.status == status).array;
  }

  ReplicationJob[] findByDistributionModel(TenantId tenantId, DistributionModelId modelId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId
        && e.distributionModelId == modelId).array;
  }

  void save(ReplicationJob job)
  {
    store[job.id] = job;
  }

  void update(ReplicationJob job)
  {
    store[job.id] = job;
  }

  void remove(ReplicationJobId id)
  {
    store.remove(id);
  }
}
