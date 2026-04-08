/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.application.usecases.manage.cleansing_jobs;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.data.quality.domain.types;
import uim.platform.data.quality.domain.entities.cleansing_job;
import uim.platform.data.quality.domain.ports.repositories.cleansing_jobs;
import uim.platform.data.quality.application.dto;

class ManageCleansingJobsUseCase : UIMUseCase {
  private CleansingJobRepository repo;

  this(CleansingJobRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateCleansingJobRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult("", "Tenant ID is required");
    if (req.datasetId.length == 0)
      return CommandResult("", "Dataset ID is required");

    auto job = CleansingJob();
    job.id = randomUUID().toString();
    job.tenantId = req.tenantId;
    job.datasetId = req.datasetId;
    job.requestedBy = req.requestedBy;
    job.status = JobStatus.pending;
    job.ruleIds = req.ruleIds;
    job.createdAt = Clock.currStdTime();

    repo.save(job);
    return CommandResult(job.id, "");
  }

  CleansingJob* getById(CleansingJobId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
  }

  CleansingJob[] listByTenant(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CleansingJob[] listByDataset(TenantId tenantId, DatasetId datasetId) {
    return repo.findByDataset(tenantId, datasetId);
  }

  CleansingJob[] listByStatus(TenantId tenantId, JobStatus status) {
    return repo.findByStatus(tenantId, status);
  }
}
