/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.quality.application.usecases.manage.cleansing_jobs;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.data.quality.domain.types;
// import uim.platform.data.quality.domain.entities.cleansing_job;
// import uim.platform.data.quality.domain.ports.repositories.cleansing_jobs;
// import uim.platform.data.quality.application.dto;
import uim.platform.data.quality;

mixin(ShowModule!());

@safe:
class ManageCleansingJobsUseCase { // TODO: UIMUseCase {
  private CleansingJobRepository repo;

  this(CleansingJobRepository repo) {
    this.repo = repo;
  }

  CommandResult createCleansingJob(CreateCleansingJobRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.datasetId.isEmpty)
      return CommandResult(false, "", "Dataset ID is required");

    CleansingJob job;
    job.initEntity(req.tenantId);

    job.datasetId = req.datasetId;
    job.requestedBy = req.requestedBy;
    job.status = JobStatus.pending;
    job.ruleIds = req.ruleIds;

    repo.save(job);
    return CommandResult(true, job.id.value, "");
  }

  CleansingJob getCleansingJob(TenantId tenantId, CleansingJobId jobId) {
    return repo.findById(tenantId, jobId);
  }

  CleansingJob[] listCleansingJobs(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CleansingJob[] listCleansingJobs(TenantId tenantId, DatasetId datasetId) {
    return repo.findByDataset(tenantId, datasetId);
  }

  CleansingJob[] listCleansingJobs(TenantId tenantId, JobStatus status) {
    return repo.findByStatus(tenantId, status);
  }
}
