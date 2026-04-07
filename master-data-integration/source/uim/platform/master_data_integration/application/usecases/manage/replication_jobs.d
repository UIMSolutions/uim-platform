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
class ManageReplicationJobsUseCase : UIMUseCase {
  private ReplicationJobRepository repo;

  this(ReplicationJobRepository repo) {
    this.repo = repo;
  }

  CommandResult create(CreateReplicationJobRequest req) {
    if (req.distributionModelId.length == 0)
      return CommandResult(false, "", "Distribution model ID is required");
    if (req.sourceClientId.length == 0)
      return CommandResult(false, "", "Source client ID is required");

    // import std.uuid : randomUUID;
    auto id = randomUUID().toString();

    ReplicationJob job;
    job.id = id;
    job.tenantId = req.tenantId;
    job.distributionModelId = req.distributionModelId;
    job.name = req.name.length > 0 ? req.name : "Replication-" ~ id[0 .. 8];
    job.description = req.description;
    job.status = ReplicationJobStatus.pending;
    job.trigger = parseTrigger(req.trigger);
    job.categories = parseCategories(req.categories);
    job.sourceClientId = req.sourceClientId;
    job.targetClientIds = req.targetClientIds;
    job.isInitialLoad = req.isInitialLoad;
    job.createdAt = clockSeconds();
    job.createdBy = req.createdBy;

    repo.save(job);
    return CommandResult(true, id, "");
  }

  CommandResult startJob(ReplicationJobId id) {
    auto job = repo.findById(id);
    if (job.id.length == 0)
      return CommandResult(false, "", "Replication job not found");
    if (job.status != ReplicationJobStatus.pending && job.status != ReplicationJobStatus.paused)
      return CommandResult(false, "", "Job can only be started from pending or paused state");

    job.status = ReplicationJobStatus.running;
    job.startedAt = clockSeconds();
    repo.update(job);
    return CommandResult(true, id, "");
  }

  CommandResult completeJob(ReplicationJobId id, long successRecords,
      long errorRecords, long skippedRecords, string[] errorMessages, string deltaToken) {
    auto job = repo.findById(id);
    if (job.id.length == 0)
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
    return CommandResult(true, id, "");
  }

  CommandResult cancelJob(ReplicationJobId id) {
    auto job = repo.findById(id);
    if (job.id.length == 0)
      return CommandResult(false, "", "Replication job not found");
    job.status = ReplicationJobStatus.cancelled;
    job.completedAt = clockSeconds();
    repo.update(job);
    return CommandResult(true, id, "");
  }

  CommandResult pauseJob(ReplicationJobId id) {
    auto job = repo.findById(id);
    if (job.id.length == 0)
      return CommandResult(false, "", "Replication job not found");
    if (job.status != ReplicationJobStatus.running)
      return CommandResult(false, "", "Job can only be paused when running");
    job.status = ReplicationJobStatus.paused;
    repo.update(job);
    return CommandResult(true, id, "");
  }

  ReplicationJob getJob(ReplicationJobId id) {
    return repo.findById(id);
  }

  ReplicationJob[] listByTenant(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  ReplicationJob[] listByStatus(TenantId tenantId, string status) {
    return repo.findByStatus(tenantId, parseJobStatus(status));
  }

  ReplicationJob[] listByDistributionModel(TenantId tenantId, DistributionModelId modelId) {
    return repo.findByDistributionModel(tenantId, modelId);
  }

  CommandResult deleteJob(ReplicationJobId id) {
    auto job = repo.findById(id);
    if (job.id.length == 0)
      return CommandResult(false, "", "Replication job not found");
    repo.remove(id);
    return CommandResult(true, id, "");
  }

  private ReplicationTrigger parseTrigger(string s) {
    switch (s)
    {
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
    switch (s)
    {
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
    foreach (s; cats)
    {
      switch (s)
      {
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

private long clockSeconds() {
  import core.time : MonoTime;

  return MonoTime.currTime.ticks / 10_000_000;
}
