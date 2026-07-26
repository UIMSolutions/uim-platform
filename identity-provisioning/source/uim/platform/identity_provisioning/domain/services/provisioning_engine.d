/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.domain.services.provisioning_engine;


// import uim.platform.identity_provisioning.domain.entities.source_system;
// import uim.platform.identity_provisioning.domain.entities.target_system;
// import uim.platform.identity_provisioning.domain.entities.provisioning_job;
// import uim.platform.identity_provisioning.domain.entities.provisioning_log;
// import uim.platform.identity_provisioning.domain.entities.provisioned_entity;
// import uim.platform.identity_provisioning.domain.ports.repositories.source_systems;
// import uim.platform.identity_provisioning.domain.ports.repositories.target_systems;
// import uim.platform.identity_provisioning.domain.ports.repositories.provisioning_jobs;
// import uim.platform.identity_provisioning.domain.ports.repositories.provisioning_logs;
// import uim.platform.identity_provisioning.domain.ports.repositories.provisioned_entitys;
import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:
/// Core domain service that orchestrates the provisioning pipeline:
/// reads entities from a source, applies transformations, and writes
/// to a target system.
class ProvisioningEngine {
  private SourceSystemRepository sourceRepo;
  private TargetSystemRepository targetRepo;
  private IProvisioningJobRepository jobRepo;
  private ProvisioningLogRepository logRepo;
  private IProvisionedEntityRepository entityRepo;

  this(SourceSystemRepository sourceRepo, TargetSystemRepository targetRepo, IProvisioningJobRepository jobRepo,
      ProvisioningLogRepository logRepo, IProvisionedEntityRepository entityRepo) {
    this.sourceRepo = sourceRepo;
    this.targetRepo = targetRepo;
    this.jobRepo = jobRepo;
    this.logRepo = logRepo;
    this.entityRepo = entityRepo;
  }

  /// Validate that a provisioning job can be started.
  bool canRun( TenantId tenantId, ProvisioningJobId jobId) {
    auto job = jobRepo.findById(tenantId, jobId);
    if (job.isNull)
      return false;

    auto src = sourceRepo.findById(tenantId, job.sourceSystemId);
    if (src.isNull || src.status != SystemStatus.active)
      return false;

    auto targetSystem = targetRepo.findById(tenantId, job.targetSystemId);
    if (targetSystem.isNull || targetSystem.status != SystemStatus.active)
      return false;

    return job.status == JobStatus.scheduled;
  }

  /// Execute a provisioning job (simulated).
  ProvisioningJob runJob(TenantId tenantId, ProvisioningJobId jobId) {
    auto job = jobRepo.findById(tenantId, jobId);
    if (job.isNull)
      return ProvisioningJob.init;

    auto now = currentTimestamp();

    // Mark running
    job.status = JobStatus.running;
    job.startedAt = now;
    jobRepo.update(job);

    auto sourceSystem = sourceRepo.findById(tenantId, job.sourceSystemId);
    auto targetSystem = targetRepo.findById(tenantId, job.targetSystemId);
    string srcName = sourceSystem.isNull ? job.sourceSystemId.value : sourceSystem.name;
    string tgtName = targetSystem.isNull ? job.targetSystemId.value : targetSystem.name;

    // Simulate provisioning 5 users and 2 groups
    simulateEntities(tenantId, job, srcName, tgtName, EntityType.user, 5);
    simulateEntities(tenantId, job, srcName, tgtName, EntityType.group, 2);

    // Complete
    job.totalEntities = 7;
    job.processedEntities = 7;
    job.failedEntities = 0;
    job.status = JobStatus.completed;
    job.completedAt = currentTimestamp();
    jobRepo.update(job);

    // Update system sync timestamps
    if (!sourceSystem.isNull) {
      sourceSystem.lastSyncAt = job.completedAt;
      sourceRepo.update(sourceSystem);
    }
    if (!targetSystem.isNull) {
      targetSystem.lastSyncAt = job.completedAt;
      targetRepo.update(targetSystem);
    }

    return job;
  }

  /// Cancel a running or scheduled job.
  bool cancelJob(TenantId tenantId, ProvisioningJobId jobId) {
    auto job = jobRepo.findById(tenantId, jobId);
    if (job.isNull)
      return false;
    if (job.status != JobStatus.running && job.status != JobStatus.scheduled)
      return false;

    job.status = JobStatus.cancelled;
    job.completedAt = currentTimestamp();
    jobRepo.update(job);
    return true;
  }

  private void simulateEntities(TenantId tenantId, ProvisioningJob job,
      string srcName, string tgtName, EntityType eType, int count) {
    auto now = currentTimestamp();
    foreach (i; 0 .. count) {
      // Create provisioned entity
      auto entity = ProvisionedEntity(tenantId); 

      entity.externalId = eType == EntityType.user ? "user-" ~ randomUUID()
        .toString()[0 .. 8] : "group-" ~ generateId()[0 .. 8];
      entity.entityType = eType;
      entity.sourceSystemId = job.sourceSystemId;
      entity.targetSystemId = job.targetSystemId;
      entity.attributes = eType == EntityType.user
        ? `{"userName":"simulated","email":"sim@example.com","active":true}`
        : `{"displayName":"simulated-group","members":[]}`;
      entity.status = EntityStatus.active;
      entity.lastSyncAt = entity.createdAt;

      entityRepo.save(entity);

      // Create log entry
      auto log = ProvisioningLog(tenantId); //, job.createdBy);
      log.jobId = job.id;
      log.entityType = eType;
      log.entityId = entity.externalId;
      log.operation = OperationType.create;
      log.status = LogStatus.success;
      log.sourceSystem = srcName;
      log.targetSystem = tgtName;
      log.details = `{"action":"created","entityId":"` ~ entity.id.value ~ `"}`;

      logRepo.save(log);
    }
  }
}
