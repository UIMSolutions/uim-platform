/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.application.usecases.manage.replication_jobs;

// import uim.platform.master_data_integration.domain.entities.replication_job;
// import uim.platform.master_data_integration.domain.ports.repositories.replication_jobs;

import uim.platform.master_data_integration;

// mixin(ShowModule!());

@safe:
/// Application service for replication job lifecycle management.
class ManageReplicationJobsUseCase { // TODO: UIMUseCase {
  private ReplicationJobRepository repo;

  this(ReplicationJobRepository repo) {
    this.repo = repo;
  }

  CommandResult createReplicationJob(CreateReplicationJobRequest req) {
    if (req.distributionModelId.isEmpty)
      return CommandResult(false, "", "Distribution model ID is required");
    if (req.sourceClientId.isEmpty)
      return CommandResult(false, "", "Source client ID is required");

    ReplicationJob job;
    job.initEntity(req.tenantId, req.createdBy);

    job.distributionModelId = req.distributionModelId;
    job.name = req.name.length > 0 ? req.name : "Replication-" ~ id[0 .. 8];
    job.description = req.description;
    job.status = ReplicationJobStatus.pending;
    job.trigger = req.trigger.to!ReplicationTrigger;
    job.categories = req.categories.map!(c => c.to!MasterDataCategory).array;
    job.sourceClientId = req.sourceClientId;
    job.targetClientIds = req.targetClientIds;
    job.isInitialLoad = req.isInitialLoad;

    repo.save(job);
    return CommandResult(true, job.id.value, "");
  }

  CommandResult startReplicationJob(TenantId tenantId, ReplicationJobId id) {
    auto job = repo.findById(tenantId, id);
    if (job.isNull)
      return CommandResult(false, "", "Replication job not found");
    if (job.status != ReplicationJobStatus.pending && job.status != ReplicationJobStatus.paused)
      return CommandResult(false, "", "Job can only be started from pending or paused state");

    job.status = ReplicationJobStatus.running;
    job.startedAt = clockSeconds();
    repo.update(job);
    return CommandResult(true, job.id.value, "");
  }

  CommandResult completeReplicationJob(TenantId tenantId, ReplicationJobId id, long successRecords,
      long errorRecords, long skippedRecords, string[] errorMessages, string deltaToken) {
    auto job = repo.findById(tenantId, id);
    if (job.isNull)
      return CommandResult(false, "", "Replication job not found");

    job.status = errorRecords > 0 ? ReplicationJobStatus.failed : ReplicationJobStatus.completed;
    job.successRecords = successRecords;
    job.errorRecords = errorRecords;
    job.skippedRecords = skippedRecords;
    job.processedRecords = successRecords + errorRecords + skippedRecords;
    job.totalRecords = job.processedRecords;
    job.errorMessages = errorMessages;
    job.lastDeltaToken = deltaToken;
    job.completedAt = clockSeconds();

    repo.update(job);
    return CommandResult(true, job.id.value, "");
  }

  CommandResult cancelReplicationJob(TenantId tenantId, ReplicationJobId id) {
    auto job = repo.findById(tenantId, id);
    if (job.isNull)
      return CommandResult(false, "", "Replication job not found");
    job.status = ReplicationJobStatus.cancelled;
    job.completedAt = clockSeconds();
    repo.update(job);
    return CommandResult(true, job.id.value, "");
  }

  CommandResult pauseReplicationJob(TenantId tenantId, ReplicationJobId id) {
    auto job = repo.findById(tenantId, id);
    if (job.isNull)
      return CommandResult(false, "", "Replication job not found");
    if (job.status != ReplicationJobStatus.running)
      return CommandResult(false, "", "Job can only be paused when running");
    job.status = ReplicationJobStatus.paused;
    repo.update(job);
    return CommandResult(true, job.id.value, "");
  }

  ReplicationJob getReplicationJob(TenantId tenantId, ReplicationJobId id) {
    return repo.findById(tenantId, id);
  }

  ReplicationJob[] listReplicationJobsByTenant(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  ReplicationJob[] listReplicationJobsByStatus(TenantId tenantId, string status) {
    return repo.findByStatus(tenantId, status.to!ReplicationJobStatus);
  }

  ReplicationJob[] listReplicationJobsByDistributionModel(TenantId tenantId, DistributionModelId modelId) {
    return repo.findByDistributionModel(tenantId, modelId);
  }

  CommandResult deleteReplicationJob(TenantId tenantId, ReplicationJobId id) {
    auto job = repo.findById(tenantId, id);
    if (job.isNull)
      return CommandResult(false, "", "Replication job not found");

    repo.remove(job);
    return CommandResult(true, job.id.value, "");
  }

}


