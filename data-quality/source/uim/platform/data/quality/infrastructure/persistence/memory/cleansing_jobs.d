/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.infrastructure.persistence.memory.cleansing_jobs;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.cleansing_job;
import uim.platform.data.quality.domain.ports.repositories.cleansing_jobs;

// import std.algorithm : filter;
// import std.array : array;

class MemoryCleansingJobRepository : CleansingJobRepository {
  private CleansingJob[CleansingJobId] store;

  CleansingJob[] findByTenant(TenantId tenantId) {
    return findAll().filter!(j => j.tenantId == tenantId).array;
  }

  CleansingJob findById(CleansingJobId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  CleansingJob[] findByDataset(TenantId tenantId, DatasetId datasetId) {
    return findAll().filter!(j => j.tenantId == tenantId && j.datasetId == datasetId).array;
  }

  CleansingJob[] findByStatus(TenantId tenantId, JobStatus status) {
    return findAll().filter!(j => j.tenantId == tenantId && j.status == status).array;
  }

  void save(CleansingJob job) {
    store[job.id] = job;
  }

  void update(CleansingJob job) {
    store[job.id] = job;
  }
}
