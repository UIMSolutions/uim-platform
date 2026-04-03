/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.application.usecases.monitor_provisioning;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.provisioning_job;
import uim.platform.identity.provisioning.domain.entities.provisioning_log;
import uim.platform.identity.provisioning.domain.entities.provisioned_entity;
import uim.platform.identity.provisioning.domain.ports.provisioning_job_repository;
import uim.platform.identity.provisioning.domain.ports.provisioning_log_repository;
import uim.platform.identity.provisioning.domain.ports.provisioned_entity_repository;
import uim.platform.identity.provisioning.domain.ports.source_system_repository;
import uim.platform.identity.provisioning.domain.ports.target_system_repository;

/// Summary of a provisioning job for monitoring dashboards.
struct JobSummary
{
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
}

/// Overall provisioning pipeline health.
struct ProvisioningSummary
{
  int totalSourceSystems;
  int activeSourceSystems;
  int totalTargetSystems;
  int activeTargetSystems;
  int totalJobs;
  int completedJobs;
  int failedJobs;
  int runningJobs;
  long totalProvisionedEntities;
}

class MonitorProvisioningUseCase
{
  private ProvisioningJobRepository jobRepo;
  private ProvisioningLogRepository logRepo;
  private ProvisionedEntityRepository entityRepo;
  private SourceSystemRepository sourceRepo;
  private TargetSystemRepository targetRepo;

  this(ProvisioningJobRepository jobRepo, ProvisioningLogRepository logRepo,
      ProvisionedEntityRepository entityRepo, SourceSystemRepository sourceRepo,
      TargetSystemRepository targetRepo)
  {
    this.jobRepo = jobRepo;
    this.logRepo = logRepo;
    this.entityRepo = entityRepo;
    this.sourceRepo = sourceRepo;
    this.targetRepo = targetRepo;
  }

  JobSummary[] listJobSummaries(TenantId tenantId)
  {
    auto jobs = jobRepo.findByTenant(tenantId);
    JobSummary[] result;
    foreach (ref j; jobs)
      result ~= buildJobSummary(j, tenantId);
    return result;
  }

  JobSummary getJobSummary(ProvisioningJobId id, TenantId tenantId)
  {
    auto job = jobRepo.findById(id, tenantId);
    if (job is null)
      return JobSummary.init;
    return buildJobSummary(*job, tenantId);
  }

  ProvisioningLog[] getJobLogs(ProvisioningJobId jobId, TenantId tenantId)
  {
    return logRepo.findByJob(jobId, tenantId);
  }

  ProvisionedEntity[] listProvisionedEntities(TenantId tenantId)
  {
    return entityRepo.findByTenant(tenantId);
  }

  ProvisionedEntity[] listByTarget(TargetSystemId targetId, TenantId tenantId)
  {
    return entityRepo.findByTarget(targetId, tenantId);
  }

  ProvisioningSummary getPipelineSummary(TenantId tenantId)
  {
    ProvisioningSummary s;

    auto sources = sourceRepo.findByTenant(tenantId);
    s.totalSourceSystems = cast(int) sources.length;
    foreach (ref src; sources)
      if (src.status == SystemStatus.active)
        s.activeSourceSystems++;

    auto targets = targetRepo.findByTenant(tenantId);
    s.totalTargetSystems = cast(int) targets.length;
    foreach (ref tgt; targets)
      if (tgt.status == SystemStatus.active)
        s.activeTargetSystems++;

    auto jobs = jobRepo.findByTenant(tenantId);
    s.totalJobs = cast(int) jobs.length;
    foreach (ref j; jobs)
    {
      if (j.status == JobStatus.completed)
        s.completedJobs++;
      else if (j.status == JobStatus.failed)
        s.failedJobs++;
      else if (j.status == JobStatus.running)
        s.runningJobs++;
    }

    auto entities = entityRepo.findByTenant(tenantId);
    s.totalProvisionedEntities = cast(long) entities.length;

    return s;
  }

  private JobSummary buildJobSummary(ref ProvisioningJob job, TenantId tenantId)
  {
    JobSummary s;
    s.jobId = job.id;
    s.jobType = job.jobType;
    s.status = job.status;
    s.totalEntities = job.totalEntities;
    s.processedEntities = job.processedEntities;
    s.failedEntities = job.failedEntities;
    s.startedAt = job.startedAt;
    s.completedAt = job.completedAt;

    auto src = sourceRepo.findById(job.sourceSystemId, tenantId);
    if (src !is null)
      s.sourceName = src.name;

    auto tgt = targetRepo.findById(job.targetSystemId, tenantId);
    if (tgt !is null)
      s.targetName = tgt.name;

    return s;
  }
}
