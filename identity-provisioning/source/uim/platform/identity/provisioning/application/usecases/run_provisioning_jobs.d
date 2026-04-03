module application.usecases.run_provisioning_jobs;

import std.uuid;
import std.datetime.systime : Clock;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.provisioning_job;
import uim.platform.xyz.domain.ports.provisioning_job_repository;
import uim.platform.xyz.domain.ports.source_system_repository;
import uim.platform.xyz.domain.ports.target_system_repository;
import uim.platform.xyz.domain.ports.provisioning_log_repository;
import uim.platform.xyz.domain.services.provisioning_engine;
import uim.platform.xyz.application.dto;

class RunProvisioningJobsUseCase
{
  private ProvisioningJobRepository repo;
  private SourceSystemRepository sourceRepo;
  private TargetSystemRepository targetRepo;
  private ProvisioningLogRepository logRepo;
  private ProvisioningEngine engine;

  this(
    ProvisioningJobRepository repo,
    SourceSystemRepository sourceRepo,
    TargetSystemRepository targetRepo,
    ProvisioningLogRepository logRepo,
    ProvisioningEngine engine)
  {
    this.repo = repo;
    this.sourceRepo = sourceRepo;
    this.targetRepo = targetRepo;
    this.logRepo = logRepo;
    this.engine = engine;
  }

  CommandResult createJob(CreateProvisioningJobRequest req)
  {
    if (req.tenantId.length == 0)
      return CommandResult("", "Tenant ID is required");
    if (req.sourceSystemId.length == 0)
      return CommandResult("", "Source system ID is required");
    if (req.targetSystemId.length == 0)
      return CommandResult("", "Target system ID is required");

    // Verify systems exist
    auto src = sourceRepo.findById(req.sourceSystemId, req.tenantId);
    if (src is null)
      return CommandResult("", "Source system not found");
    auto tgt = targetRepo.findById(req.targetSystemId, req.tenantId);
    if (tgt is null)
      return CommandResult("", "Target system not found");

    auto now = Clock.currStdTime();
    auto job = ProvisioningJob();
    job.id = randomUUID().toString();
    job.tenantId = req.tenantId;
    job.sourceSystemId = req.sourceSystemId;
    job.targetSystemId = req.targetSystemId;
    job.jobType = req.jobType;
    job.status = JobStatus.scheduled;
    job.schedule = req.schedule;
    job.createdBy = req.createdBy;
    job.createdAt = now;

    repo.save(job);
    return CommandResult(job.id, "");
  }

  /// Run a previously created job.
  CommandResult runJob(ProvisioningJobId id, TenantId tenantId)
  {
    if (!engine.canRun(id, tenantId))
      return CommandResult("", "Job cannot be started - verify systems are active and job is scheduled");

    auto result = engine.runJob(id, tenantId);
    if (result is null)
      return CommandResult("", "Failed to execute provisioning job");

    return CommandResult(result.id, "");
  }

  /// Create and immediately run a job.
  CommandResult createAndRunJob(CreateProvisioningJobRequest req)
  {
    auto createResult = createJob(req);
    if (!createResult.isSuccess)
      return createResult;

    return runJob(createResult.id, req.tenantId);
  }

  CommandResult cancelJob(ProvisioningJobId id, TenantId tenantId)
  {
    if (!engine.cancelJob(id, tenantId))
      return CommandResult("", "Job cannot be cancelled");

    return CommandResult(id, "");
  }

  ProvisioningJob* getJob(ProvisioningJobId id, TenantId tenantId)
  {
    return repo.findById(id, tenantId);
  }

  ProvisioningJob[] listJobs(TenantId tenantId)
  {
    return repo.findByTenant(tenantId);
  }

  ProvisioningJob[] listByStatus(TenantId tenantId, JobStatus status)
  {
    return repo.findByStatus(tenantId, status);
  }

  CommandResult deleteJob(ProvisioningJobId id, TenantId tenantId)
  {
    auto existing = repo.findById(id, tenantId);
    if (existing is null)
      return CommandResult("", "Provisioning job not found");

    if (existing.status == JobStatus.running)
      return CommandResult("", "Cannot delete a running job");

    // Cascade delete logs
    logRepo.removeByJob(id, tenantId);
    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
