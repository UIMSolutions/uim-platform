/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.application.usecases.run_provisioning_jobs;


// import uim.platform.identity_provisioning.domain.entities.provisioning_job;
// import uim.platform.identity_provisioning.domain.ports.repositories.provisioning_jobs;
// import uim.platform.identity_provisioning.domain.ports.repositories.source_systems;
// import uim.platform.identity_provisioning.domain.ports.repositories.target_systems;
// import uim.platform.identity_provisioning.domain.ports.repositories.provisioning_logs;
// import uim.platform.identity_provisioning.domain.services.provisioning_engine;
// import uim.platform.identity_provisioning.application.dto;
import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:
class RunProvisioningJobsUseCase {
  protected IProvisioningJobRepository repo;
  private ISourceSystemRepository sourceRepo;
  private ITargetSystemRepository targetRepo;
  private IProvisioningLogRepository logRepo;
  private ProvisioningEngine engine;

  this(IProvisioningJobRepository repo, ISourceSystemRepository sourceRepo,
      ITargetSystemRepository targetRepo, IProvisioningLogRepository logRepo,
      ProvisioningEngine engine) {
    this.repo = repo;
    this.sourceRepo = sourceRepo;
    this.targetRepo = targetRepo;
    this.logRepo = logRepo;
    this.engine = engine;
  }

  UsecaseResult createJob(CreateProvisioningJobRequest req) {
    if (req.tenantId.isEmpty)
      return UsecaseResult(false, "", "Tenant ID is required");
    if (req.sourceSystemId.isEmpty)
      return UsecaseResult(false, "", "Source system ID is required");
    if (req.targetSystemId.isEmpty)
      return UsecaseResult(false, "", "Target system ID is required");

    // Verify systems exist
    auto src = sourceRepo.findById(req.tenantId, req.sourceSystemId);
    if (src.isNull)
      return UsecaseResult(false, "", "Source system not found");
    auto tgt = targetRepo.findById(req.tenantId, req.targetSystemId);
    if (tgt.isNull)
      return UsecaseResult(false, "", "Target system not found");

    auto job = ProvisioningJob(req.tenantId); //, req.createdBy);
    job.sourceSystemId = req.sourceSystemId;
    job.targetSystemId = req.targetSystemId;
    job.jobType = req.jobType;
    job.status = JobStatus.scheduled;
    job.schedule = req.schedule;

    repo.save(job);
    return UsecaseResult(true, job.id.value, "");
  }

  /// Run a previously created job.
  UsecaseResult runJob(TenantId tenantId, ProvisioningJobId id) {
    if (!engine.canRun(tenantId, id))
      return UsecaseResult(false, "", "Job cannot be started - verify systems are active and job is scheduled");

    auto result = engine.runJob(tenantId, id);
    if (result.isNull)
      return UsecaseResult(false, "", "Failed to execute provisioning job");

    return UsecaseResult(true, result.id.value, "");
  }

  /// Create and immediately run a job.
  UsecaseResult createAndRunJob(CreateProvisioningJobRequest req) {
    auto createResult = createJob(req);
    if (!createResult.isSuccess)
      return createResult;

    return runJob(req.tenantId, ProvisioningJobId(createResult.id));
  }

  UsecaseResult cancelJob(TenantId tenantId, ProvisioningJobId id) {
    if (!engine.cancelJob(tenantId, id))
      return UsecaseResult(false, "", "Job cannot be cancelled");

    return UsecaseResult(true, id.value, "");
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

  UsecaseResult deleteJob(TenantId tenantId, ProvisioningJobId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return UsecaseResult(false, "", "Provisioning job not found");

    if (existing.status == JobStatus.running)
      return UsecaseResult(false, "", "Cannot delete a running job");

    // Cascade delete logs
    logRepo.removeByJob(tenantId, id);
    
    repo.remove(existing);
    return UsecaseResult(true, id.value, "");
  }
}

///
unittest {
//     auto iProvisioningJobRepository = new IProvisioningJobRepository();
//     auto iSourceSystemRepository = new ISourceSystemRepository();
//     auto iTargetSystemRepository = new ITargetSystemRepository();
//     auto iProvisioningLogRepository = new IProvisioningLogRepository();
//     auto provisioningEngine = new ProvisioningEngine();
//     auto usecase = new RunProvisioningJobsUseCase(iProvisioningJobRepository, iSourceSystemRepository, iTargetSystemRepository, iProvisioningLogRepository, provisioningEngine);
//     auto tenantId = TenantId("test-tenant");
// 
//     // Test list
//     auto items = usecase.listJobs(tenantId);
//     assert(items !is null);

}
