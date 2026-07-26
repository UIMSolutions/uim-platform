/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.application.usecases.monitor_provisioning;

// import uim.platform.identity_provisioning.domain.entities.provisioning_job;
// import uim.platform.identity_provisioning.domain.entities.provisioning_log;
// import uim.platform.identity_provisioning.domain.entities.provisioned_entity;
// import uim.platform.identity_provisioning.domain.ports.repositories.provisioning_jobs;
// import uim.platform.identity_provisioning.domain.ports.repositories.provisioning_logs;
// import uim.platform.identity_provisioning.domain.ports.repositories.provisioned_entitys;
// import uim.platform.identity_provisioning.domain.ports.repositories.source_systems;
// import uim.platform.identity_provisioning.domain.ports.repositories.target_systems;
import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:
/// Summary of a provisioning job for monitoring dashboards.
struct JobSummary {
  ProvisioningJobId jobId;
  string sourceName;
  string targetName;
  JobType jobType;
  JobStatus status;
  long totalEntities;
  long processedEntities;
  long failedEntities;
  long startedAt;
  long completedAt;

  Json toJson() const {
    return Json.emptyObject
      .set("jobId", jobId)
      .set("sourceName", sourceName)
      .set("targetName", targetName)
      .set("jobType", jobType.to!string)
      .set("status", status.to!string)
      .set("totalEntities", totalEntities)
      .set("processedEntities", processedEntities)
      .set("failedEntities", failedEntities)
      .set("startedAt", startedAt)
      .set("completedAt", completedAt);
  }
}

/// Overall provisioning pipeline health.
struct ProvisioningSummary {
  int totalSourceSystems;
  int activeSourceSystems;
  int totalTargetSystems;
  int activeTargetSystems;
  size_t totalJobs;
  int completedJobs;
  int failedJobs;
  int runningJobs;
  long totalProvisionedEntities;
}

class MonitorProvisioningUseCase { // TODO: UIMUseCase {
  private IProvisioningJobRepository jobRepo;
  private ProvisioningLogRepository logRepo;
  private IProvisionedEntityRepository entityRepo;
  private SourceSystemRepository sourceRepo;
  private TargetSystemRepository targetRepo;

  this(IProvisioningJobRepository jobRepo, ProvisioningLogRepository logRepo,
      IProvisionedEntityRepository entityRepo, SourceSystemRepository sourceRepo,
      TargetSystemRepository targetRepo) {
    this.jobRepo = jobRepo;
    this.logRepo = logRepo;
    this.entityRepo = entityRepo;
    this.sourceRepo = sourceRepo;
    this.targetRepo = targetRepo;
  }

  JobSummary[] listJobSummaries(TenantId tenantId) {
    auto jobs = jobRepo.findByTenant(tenantId);
    return jobs.map!(job => buildJobSummary(tenantId, job)).array;
  }

  JobSummary getJobSummary(TenantId tenantId, ProvisioningJobId jobId) {
    auto job = jobRepo.findById(tenantId, jobId);
    if (job.isNull)
      return JobSummary.init;

    return buildJobSummary(tenantId, job);
  }

  ProvisioningLog[] getJobLogs(TenantId tenantId, ProvisioningJobId jobId) {
    return logRepo.findByJob(tenantId, jobId);
  }

  ProvisionedEntity[] listProvisionedEntities(TenantId tenantId) {
    return entityRepo.findByTenant(tenantId);
  }

  ProvisionedEntity[] listByTarget(TenantId tenantId, TargetSystemId systemId) {
    return entityRepo.findByTarget(tenantId, systemId);
  }

  ProvisioningSummary getPipelineSummary(TenantId tenantId) {
    ProvisioningSummary s;

    auto sources = sourceRepo.findByTenant(tenantId);
    s.totalSourceSystems = cast(int) sources.length;
    foreach (src; sources)
      if (src.status == SystemStatus.active)
        s.activeSourceSystems++;

    auto targets = targetRepo.findByTenant(tenantId);
    s.totalTargetSystems = cast(int) targets.length;
    foreach (tgt; targets)
      if (tgt.status == SystemStatus.active)
        s.activeTargetSystems++;

    auto jobs = jobRepo.findByTenant(tenantId);
    s.totalJobs = jobs.length;
    foreach (j; jobs) {
      if (j.status == JobStatus.completed)
        s.completedJobs++;
      else if (j.status == JobStatus.failed)
        s.failedJobs++;
      else if (j.status == JobStatus.running)
        s.runningJobs++;
    }

    auto entities = entityRepo.findByTenant(tenantId);
    s.totalProvisionedEntities = entities.length;

    return s;
  }

  private JobSummary buildJobSummary(TenantId tenantId, ProvisioningJob job) {
    JobSummary s;
    s.jobId = job.id;
    s.jobType = job.jobType;
    s.status = job.status;
    s.totalEntities = job.totalEntities;
    s.processedEntities = job.processedEntities;
    s.failedEntities = job.failedEntities;
    s.startedAt = job.startedAt;
    s.completedAt = job.completedAt;

    auto src = sourceRepo.findById(tenantId, job.sourceSystemId);
    if (!src.isNull)
      s.sourceName = src.name;

    auto tgt = targetRepo.findById(tenantId, job.targetSystemId);
    if (!tgt.isNull)
      s.targetName = tgt.name;

    return s;
  }
}
