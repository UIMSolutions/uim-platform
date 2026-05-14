/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.master_data_integration.application.usecases.manage.replication_jobs;

import uim.platform.master_data_integration.application.dto;
import uim.platform.master_data_integration.domain.entities.replication_job;
import uim.platform.master_data_integration.domain.ports.repositories.replication_jobs;
import uim.platform.master_data_integration.domain.types;

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
    job.trigger = parseTrigger(req.trigger);
    job.categories = parseCategories(req.categories);
    job.sourceClientId = req.sourceClientId;
    job.targetClientIds = req.targetClientIds;
    job.isInitialLoad = req.isInitialLoad;

    repo.save(job);
    return CommandResult(true, job.id.value, "");
  }

  CommandResult startReplicationJob(ReplicationJobId id) {
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

  CommandResult completeReplicationJob(ReplicationJobId id, long successRecords,
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
    return CommandResult(true, id.value, "");
  }

  CommandResult cancelReplicationJob(ReplicationJobId id) {
    auto job = repo.findById(tenantId, id);
    if (job.isNull)
      return CommandResult(false, "", "Replication job not found");
    job.status = ReplicationJobStatus.cancelled;
    job.completedAt = clockSeconds();
    repo.update(job);
    return CommandResult(true, job.id.value, "");
  }

  CommandResult pauseReplicationJob(ReplicationJobId id) {
    auto job = repo.findById(tenantId, id);
    if (job.isNull)
      return CommandResult(false, "", "Replication job not found");
    if (job.status != ReplicationJobStatus.running)
      return CommandResult(false, "", "Job can only be paused when running");
    job.status = ReplicationJobStatus.paused;
    repo.update(job);
    return CommandResult(true, job.id.value, "");
  }

  ReplicationJob getReplicationJob(ReplicationJobId id) {
    return repo.findById(tenantId, id);
  }

  ReplicationJob[] listReplicationJobsByTenant(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  ReplicationJob[] listReplicationJobsByStatus(TenantId tenantId, string status) {
    return repo.findByStatus(tenantId, parseJobStatus(status));
  }

  ReplicationJob[] listReplicationJobsByDistributionModel(TenantId tenantId, DistributionModelId modelId) {
    return repo.findByDistributionModel(tenantId, modelId);
  }

  CommandResult deleteReplicationJob(ReplicationJobId id) {
    auto job = repo.findById(tenantId, id);
    if (job.isNull)
      return CommandResult(false, "", "Replication job not found");
    repo.removeById(id);
    return CommandResult(true, job.id.value, "");
  }

  private ReplicationTrigger parseTrigger(string s) {
    switch (s) {
    case "manual":
      return ReplicationTrigger.manual;
    case "scheduled":
      return ReplicationTrigger.scheduled;
    case "eventDriven":
      return ReplicationTrigger.eventDriven;
    case "onChange":
      return ReplicationTrigger.onChange;
    default:
      return ReplicationTrigger.manual;
    }
  }

  private ReplicationJobStatus parseJobStatus(string s) {
    switch (s) {
    case "pending":
      return ReplicationJobStatus.pending;
    case "running":
      return ReplicationJobStatus.running;
    case "completed":
      return ReplicationJobStatus.completed;
    case "failed":
      return ReplicationJobStatus.failed;
    case "cancelled":
      return ReplicationJobStatus.cancelled;
    case "paused":
      return ReplicationJobStatus.paused;
    default:
      return ReplicationJobStatus.pending;
    }
  }

  private MasterDataCategory[] parseCategories(string[] cats) {
    MasterDataCategory[] result;
    foreach (s; cats) {
      switch (s) {
      case "businessPartner":
        result ~= MasterDataCategory.businessPartner;
        break;
      case "costCenter":
        result ~= MasterDataCategory.costCenter;
        break;
      case "profitCenter":
        result ~= MasterDataCategory.profitCenter;
        break;
      case "companyCode":
        result ~= MasterDataCategory.companyCode;
        break;
      case "workforcePerson":
        result ~= MasterDataCategory.workforcePerson;
        break;
      case "custom":
        result ~= MasterDataCategory.custom;
        break;
      default:
        break;
      }
    }
    return result;
  }
}


