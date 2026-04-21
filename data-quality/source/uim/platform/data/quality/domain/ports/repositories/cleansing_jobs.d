/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.ports.repositories.cleansing_jobs;

// import uim.platform.data.quality.domain.types;
// import uim.platform.data.quality.domain.entities.cleansing_job;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
/// Port for persisting cleansing job records.
interface CleansingJobRepository : ITenantRepository!(CleansingJob, CleansingJobId) {

  size_t countByDataset(TenantId tenantId, DatasetId datasetId);
  CleansingJob[] findByDataset(TenantId tenantId, DatasetId datasetId);
  void removeByDataset(TenantId tenantId, DatasetId datasetId);

  size_t countByStatus(TenantId tenantId, JobStatus status);
  CleansingJob[] findByStatus(TenantId tenantId, JobStatus status);
  void removeByStatus(TenantId tenantId, JobStatus status);
  
}
