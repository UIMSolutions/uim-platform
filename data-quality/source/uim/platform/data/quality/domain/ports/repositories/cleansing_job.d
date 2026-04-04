/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.domain.ports.repositories.cleansing_jobs;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.cleansing_job;

/// Port for persisting cleansing job records.
interface CleansingJobRepository {
  CleansingJob[] findByTenant(TenantId tenantId);
  CleansingJob* findById(CleansingJobId id, TenantId tenantId);
  CleansingJob[] findByDataset(TenantId tenantId, DatasetId datasetId);
  CleansingJob[] findByStatus(TenantId tenantId, JobStatus status);
  void save(CleansingJob job);
  void update(CleansingJob job);
}
