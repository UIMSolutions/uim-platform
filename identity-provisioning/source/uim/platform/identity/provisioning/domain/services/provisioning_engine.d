module uim.platform.xyz.domain.services.provisioning_engine;

import std.uuid;
import std.datetime.systime : Clock;

import domain.types;
import domain.entities.source_system;
import domain.entities.target_system;
import domain.entities.provisioning_job;
import domain.entities.provisioning_log;
import domain.entities.provisioned_entity;
import domain.ports.source_system_repository;
import domain.ports.target_system_repository;
import domain.ports.provisioning_job_repository;
import domain.ports.provisioning_log_repository;
import domain.ports.provisioned_entity_repository;

/// Core domain service that orchestrates the provisioning pipeline:
/// reads entities from a source, applies transformations, and writes
/// to a target system.
class ProvisioningEngine
{
  private SourceSystemRepository sourceRepo;
  private TargetSystemRepository targetRepo;
  private ProvisioningJobRepository jobRepo;
  private ProvisioningLogRepository logRepo;
  private ProvisionedEntityRepository entityRepo;

  this(
    SourceSystemRepository sourceRepo,
    TargetSystemRepository targetRepo,
    ProvisioningJobRepository jobRepo,
    ProvisioningLogRepository logRepo,
    ProvisionedEntityRepository entityRepo)
  {
    this.sourceRepo = sourceRepo;
    this.targetRepo = targetRepo;
    this.jobRepo = jobRepo;
    this.logRepo = logRepo;
    this.entityRepo = entityRepo;
  }

  /// Validate that a provisioning job can be started.
  bool canRun(ProvisioningJobId jobId, TenantId tenantId)
  {
    auto job = jobRepo.findById(jobId, tenantId);
    if (job is null)
      return false;

    auto src = sourceRepo.findById(job.sourceSystemId, tenantId);
    if (src is null || src.status != SystemStatus.active)
      return false;

    auto tgt = targetRepo.findById(job.targetSystemId, tenantId);
    if (tgt is null || tgt.status != SystemStatus.active)
      return false;

    return job.status == JobStatus.scheduled;
  }

  /// Execute a provisioning job (simulated).
  ProvisioningJob* runJob(ProvisioningJobId jobId, TenantId tenantId)
  {
    auto job = jobRepo.findById(jobId, tenantId);
    if (job is null)
      return null;

    auto now = Clock.currStdTime();

    // Mark running
    job.status = JobStatus.running;
    job.startedAt = now;
    jobRepo.update(*job);

    auto src = sourceRepo.findById(job.sourceSystemId, tenantId);
    auto tgt = targetRepo.findById(job.targetSystemId, tenantId);
    string srcName = src !is null ? src.name : job.sourceSystemId;
    string tgtName = tgt !is null ? tgt.name : job.targetSystemId;

    // Simulate provisioning 5 users and 2 groups
    simulateEntities(job, tenantId, srcName, tgtName, EntityType.user, 5);
    simulateEntities(job, tenantId, srcName, tgtName, EntityType.group, 2);

    // Complete
    job.totalEntities = 7;
    job.processedEntities = 7;
    job.failedEntities = 0;
    job.status = JobStatus.completed;
    job.completedAt = Clock.currStdTime();
    jobRepo.update(*job);

    // Update system sync timestamps
    if (src !is null)
    {
      src.lastSyncAt = job.completedAt;
      sourceRepo.update(*src);
    }
    if (tgt !is null)
    {
      tgt.lastSyncAt = job.completedAt;
      targetRepo.update(*tgt);
    }

    return job;
  }

  /// Cancel a running or scheduled job.
  bool cancelJob(ProvisioningJobId jobId, TenantId tenantId)
  {
    auto job = jobRepo.findById(jobId, tenantId);
    if (job is null)
      return false;
    if (job.status != JobStatus.running && job.status != JobStatus.scheduled)
      return false;

    job.status = JobStatus.cancelled;
    job.completedAt = Clock.currStdTime();
    jobRepo.update(*job);
    return true;
  }

  private void simulateEntities(
    ProvisioningJob* job, TenantId tenantId,
    string srcName, string tgtName,
    EntityType eType, int count)
  {
    auto now = Clock.currStdTime();
    foreach (i; 0 .. count)
    {
      // Create provisioned entity
      auto entity = ProvisionedEntity();
      entity.id = randomUUID().toString();
      entity.tenantId = tenantId;
      entity.externalId = eType == EntityType.user
        ? "user-" ~ randomUUID().toString()[0 .. 8]
        : "group-" ~ randomUUID().toString()[0 .. 8];
      entity.entityType = eType;
      entity.sourceSystemId = job.sourceSystemId;
      entity.targetSystemId = job.targetSystemId;
      entity.attributes = eType == EntityType.user
        ? `{"userName":"simulated","email":"sim@example.com","active":true}`
        : `{"displayName":"simulated-group","members":[]}`  ;
      entity.status = EntityStatus.active;
      entity.lastSyncAt = now;
      entity.createdAt = now;
      entity.updatedAt = now;
      entityRepo.save(entity);

      // Create log entry
      auto log = ProvisioningLog();
      log.id = randomUUID().toString();
      log.tenantId = tenantId;
      log.jobId = job.id;
      log.entityType = eType;
      log.entityId = entity.externalId;
      log.operation = OperationType.create;
      log.status = LogStatus.success;
      log.sourceSystem = srcName;
      log.targetSystem = tgtName;
      log.details = `{"action":"created","entityId":"` ~ entity.id ~ `"}`;
      log.createdAt = now;
      logRepo.save(log);
    }
  }
}
