/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.application.usecases.run_provisioning_jobs;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.identity.provisioning.domain.types;
// import uim.platform.identity.provisioning.domain.entities.provisioning_job;
// import uim.platform.identity.provisioning.domain.ports.repositories.provisioning_jobs;
// import uim.platform.identity.provisioning.domain.ports.repositories.source_systems;
// import uim.platform.identity.provisioning.domain.ports.repositories.target_systems;
// import uim.platform.identity.provisioning.domain.ports.repositories.provisioning_logs;
// import uim.platform.identity.provisioning.domain.services.provisioning_engine;
// import uim.platform.identity.provisioning.application.dto;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
class RunProvisioningJobsUseCase { // TODO: UIMUseCase {
  private ProvisioningJobRepository repo;
  private SourceSystemRepository sourceRepo;
  private TargetSystemRepository targetRepo;
  private ProvisioningLogRepository logRepo;
  private ProvisioningEngine engine;

  this(ProvisioningJobRepository repo, SourceSystemRepository sourceRepo,
      TargetSystemRepository targetRepo, ProvisioningLogRepository logRepo,
      ProvisioningEngine engine) {
    this.repo = repo;
    this.sourceRepo = sourceRepo;
    this.targetRepo = targetRepo;
    this.logRepo = logRepo;
    this.engine = engine;
  }

  CommandResult createJob(CreateProvisioningJobRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.sourceSystemId.isEmpty)
      return CommandResult(false, "", "Source system ID is required");
    if (req.targetSystemId.isEmpty)
      return CommandResult(false, "", "Target system ID is required");

    // Verify systems exist
    auto src = sourceRepo.findById(req.tenantId, req.sourceSystemId);
    if (src.isNull)
      return CommandResult(false, "", "Source system not found");
    auto tgt = targetRepo.findById(req.tenantId, req.targetSystemId);
    if (tgt.isNull)
      return CommandResult(false, "", "Target system not found");

    auto now = Clock.currStdTime();
    auto job = ProvisioningJob();
    job.id = randomUUID();
    job.tenantId = req.tenantId;
    job.sourceSystemId = req.sourceSystemId;
    job.targetSystemId = req.targetSystemId;
    job.jobType = req.jobType;
    job.status = JobStatus.scheduled;
    job.schedule = req.schedule;
    job.createdBy = req.createdBy;
    job.createdAt = now;

    repo.save(job);
    return CommandResult(true, job.id.value, "");
  }

  /// Run a previously created job.
  CommandResult runJob(TenantId tenantId, ProvisioningJobId id) {
    if (!engine.canRun(tenantId, id))
      return CommandResult(false, "", "Job cannot be started - verify systems are active and job is scheduled");

    auto result = engine.runJob(tenantId, id);
    if (result.isNull)
      return CommandResult(false, "", "Failed to execute provisioning job");

    return CommandResult(true, result.id.value, "");
  }

  /// Create and immediately run a job.
  CommandResult createAndRunJob(CreateProvisioningJobRequest req) {
    auto createResult = createJob(req);
    if (!createResult.isSuccess)
      return createResult;

    return runJob(req.tenantId, createResult.id);
  }

  CommandResult cancelJob(TenantId tenantId, ProvisioningJobId id) {
    if (!engine.cancelJob(tenantId, id))
      return CommandResult(false, "", "Job cannot be cancelled");

    return CommandResult(true, id.value, "");
  }

  ProvisioningJob getJob(TenantId tenantId, ProvisioningJobId id) {
    return repo.findById(tenantId, id);
  }

  ProvisioningJob[] listJobs(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  ProvisioningJob[] listByStatus(TenantId tenantId, JobStatus status) {
    return repo.findByStatus(tenantId, status);
  }

  CommandResult deleteJob(TenantId tenantId, ProvisioningJobId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, "", "Provisioning job not found");

    if (existing.status == JobStatus.running)
      return CommandResult(false, "", "Cannot delete a running job");

    // Cascade delete logs
    logRepo.removeByJob(tenantId, id);
    repo.removeById(tenantId, id);
    return CommandResult(true, id.value, "");
  }
}
