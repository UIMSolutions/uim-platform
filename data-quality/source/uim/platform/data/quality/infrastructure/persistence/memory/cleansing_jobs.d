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

class MemoryCleansingJobRepository : TenantRepository!(CleansingJob, CleansingJobId), CleansingJobRepository {

  // #region ByDataset
  size_t countByDataset(TenantId tenantId, DatasetId datasetId) {
    return findByDataset(tenantId, datasetId).length;
  }

  CleansingJob[] filterByDataset(CleansingJob[] jobs, DatasetId datasetId) {
    return jobs.filter!(j => j.datasetId == datasetId).array;
  }

  CleansingJob[] findByDataset(TenantId tenantId, DatasetId datasetId) {
    return filterByDataset(findByTenant(tenantId), datasetId);
  }

  void removeByDataset(TenantId tenantId, DatasetId datasetId) {
    findByDataset(tenantId, datasetId).each!(entity => remove(entity));
  }
  // #endregion ByDataset

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, JobStatus status) {
    return findByStatus(tenantId, status).length;
  }

  CleansingJob[] filterByStatus(CleansingJob[] jobs, JobStatus status) {
    return jobs.filter!(j => j.status == status).array;
  }

  CleansingJob[] findByStatus(TenantId tenantId, JobStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, JobStatus status) {
    findByStatus(tenantId, status).each!(entity => remove(entity));
  }
  // #endregion ByStatus
  
}
