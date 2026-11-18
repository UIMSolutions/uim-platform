/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.application.services.runner;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Executes one provisioning run:
///
///   1. read all identities of the source system (connector)
///   2. apply the read transformations of the source, then the write
///      transformations of the target (filters skip, mandatory mappings fail)
///   3. plan create / update / delete / skip against the delta state
///   4. write the target (connector) — or only log the plan (simulate)
///   5. store delta state, audit log and the job figures
///
/// Log entries and entity changes are written in batches (one snapshot write
/// per collection and run).
class ProvisioningRunner {
  protected ProvisioningRepositories repos;
  protected IIdentityConnector connector;
  protected EventRecorder events;

  this(ProvisioningRepositories repos, IIdentityConnector connector, EventRecorder events) {
    this.repos = repos;
    this.connector = connector;
    this.events = events;
  }

  /// Run `job` (which must be runnable). Returns the updated job.
  ProvisioningJob execute(ProvisioningJob job, UserId actor) {
    auto t = job.tenantId;
    auto source = repos.sourceSystems.findById(t, job.sourceSystemId);
    if (source.isNull)
      throw new ProvisioningNotFoundException("Source system '" ~ job.sourceSystemId.value ~ "' not found");
    auto target = repos.targetSystems.findById(t, job.targetSystemId);
    if (target.isNull)
      throw new ProvisioningNotFoundException("Target system '" ~ job.targetSystemId.value ~ "' not found");
    ensureSystemActive("Source", source.name, source.status);
    ensureSystemActive("Target", target.name, target.status);

    // ── start ─────────────────────────────────────────────────────────────
    job.status = JobStatus.running;
    job.startedAt = nowStdTime();
    job.completedAt = 0;
    job.runCount++;
    job.readCount = job.createdCount = job.updatedCount = job.deletedCount = job.skippedCount = job.failedCount = 0;
    job.statusMessage = "";
    job.update(actor);
    repos.jobs.update(job);

    auto run = Run(job, source.name, target.name);
    bool connectorFailed;
    try {
      auto identities = connector.read(source.connection);
      job.readCount = cast(int) identities.length;
      source.lastSyncAt = nowStdTime();
      source.entityCount = job.readCount;
      repos.sourceSystems.update(source);

      auto readRules = repos.transformations.findBySystem(t, SystemRole.source, source.id.value);
      auto writeRules = repos.transformations.findBySystem(t, SystemRole.target, target.id.value);

      SourceIdentity[] accepted;
      foreach (identity; identities) {
        auto r = transformAll(readRules, identity.entityType, identity.attributes);
        if (r.accepted)
          r = transformAll(writeRules, identity.entityType, r.attributes);
        if (r.accepted) {
          accepted ~= SourceIdentity(identity.externalId, identity.entityType, identity.name, r.attributes);
          continue;
        }
        if (r.failed) {
          job.failedCount++;
          run.log(OperationType.skip, identity.entityType, identity.externalId, identity.name, LogStatus.failed, r.reason);
        } else {
          job.skippedCount++;
          run.log(OperationType.skip, identity.entityType, identity.externalId, identity.name, LogStatus.skipped, r.reason);
        }
      }

      auto plan = planOperations(job.jobType, accepted, repos.entities.findByPair(t, source.id, target.id));
      foreach (op; plan)
        apply(job, target, op, run);
    } catch (ConnectorException e) {
      connectorFailed = true;
      job.statusMessage = "Connector error: " ~ e.msg;
      run.log(OperationType.skip, EntityType.user, "", "", LogStatus.failed, job.statusMessage);
    }

    // ── persist in batches ────────────────────────────────────────────────
    if (run.created.length)
      repos.entities.save(run.created);
    if (run.changed.length)
      repos.entities.update(run.changed);
    if (run.removed.length)
      repos.entities.remove(run.removed);
    if (run.logs.length)
      repos.logs.save(run.logs);

    // ── finish ────────────────────────────────────────────────────────────
    job.completedAt = nowStdTime();
    job.status = statusAfterRun(job.failedCount, connectorFailed);
    job.nextRunAt = nextRunAfter(job.completedAt, job.intervalMinutes);
    if (!connectorFailed)
      job.statusMessage = summary(job);
    repos.jobs.update(job);

    if (job.jobType != JobType.simulate) {
      target.lastSyncAt = job.completedAt;
      target.entityCount = cast(int) repos.entities.findByTarget(t, target.id).length;
      repos.targetSystems.update(target);
    }

    auto payload = Json.emptyObject;
    payload["tenantId"] = t.value;
    payload["id"] = job.id.value;
    payload["name"] = job.name;
    payload["status"] = enumText(job.status);
    payload["message"] = job.statusMessage;
    events.publish("provisioning.job." ~ enumText(job.status), payload);
    return job;
  }

  /// "7 read · 5 created · 1 updated · 0 deleted · 1 skipped · 0 failed (simulated)".
  static string summary(const ProvisioningJob job) {
    return "%d read · %d created · %d updated · %d deleted · %d skipped · %d failed%s".format(job.readCount,
      job.createdCount, job.updatedCount, job.deletedCount, job.skippedCount, job.failedCount,
      job.jobType == JobType.simulate ? " (simulated)" : "");
  }

  // ── one operation ──────────────────────────────────────────────────────

  protected void apply(ref ProvisioningJob job, const TargetSystem target, PlannedOperation op, ref Run run) {
    void count() {
      final switch (op.operation) {
      case OperationType.create:
        job.createdCount++;
        break;
      case OperationType.update:
        job.updatedCount++;
        break;
      case OperationType.delete_:
        job.deletedCount++;
        break;
      case OperationType.skip:
        job.skippedCount++;
        break;
      }
    }

    if (op.operation == OperationType.skip) {
      count();
      run.log(op, LogStatus.skipped, op.reason);
      return;
    }
    if (job.jobType == JobType.simulate) {
      count();
      run.log(op, LogStatus.simulated, "would " ~ enumText(op.operation) ~ ": " ~ op.reason);
      return;
    }

    auto existing = op.existingId.isEmpty ? ProvisionedEntity.init : repos.entities.findById(job.tenantId, op.existingId);
    try {
      if (op.operation == OperationType.delete_) {
        connector.remove(target.connection, op);
        if (!existing.isNull)
          run.removed ~= existing;
        count();
        run.log(op, LogStatus.success, op.reason);
        return;
      }
      auto targetId = connector.write(target.connection, op);
      run.upsert(existing, job, target, op, targetId, EntityStatus.active, "");
      count();
      run.log(op, LogStatus.success, op.reason);
    } catch (ConnectorException e) {
      job.failedCount++;
      if (op.operation != OperationType.delete_)
        run.upsert(existing, job, target, op, op.targetId, EntityStatus.error, e.msg);
      run.log(op, LogStatus.failed, e.msg);
    }
  }
}

/// Collected changes of one run (written in batches).
private struct Run {
  ProvisioningJob job;
  string sourceName, targetName;
  ProvisioningLog[] logs;
  ProvisionedEntity[] created, changed, removed;

  this(ProvisioningJob job, string sourceName, string targetName) {
    this.job = job;
    this.sourceName = sourceName;
    this.targetName = targetName;
  }

  void log(OperationType operation, EntityType type, string externalId, string name, LogStatus status, string message) {
    auto l = ProvisioningLog(job.tenantId);
    l.name = logName(operation, type, name.length ? name : externalId);
    l.jobId = job.id;
    l.jobName = job.name;
    l.runNumber = job.runCount;
    l.entityType = type;
    l.externalId = externalId;
    l.entityName = name;
    l.operation = operation;
    l.status = status;
    l.sourceSystemName = sourceName;
    l.targetSystemName = targetName;
    l.message = message;
    // keep the order of a run stable (newest first sorting uses createdAt)
    l.createdAt += logs.length;
    l.updatedAt = l.createdAt;
    logs ~= l;
  }

  void log(const PlannedOperation op, LogStatus status, string message) {
    log(op.operation, op.entityType, op.externalId, op.name, status, message);
  }

  void upsert(ProvisionedEntity existing, const ProvisioningJob job, const TargetSystem target,
      const PlannedOperation op, string targetId, EntityStatus status, string message) {
    bool isNew = existing.isNull;
    auto e = isNew ? ProvisionedEntity(job.tenantId) : existing;
    e.name = op.name;
    e.entityType = op.entityType;
    e.externalId = op.externalId;
    e.targetId = targetId;
    e.sourceSystemId = job.sourceSystemId;
    e.targetSystemId = job.targetSystemId;
    e.targetSystemName = target.name;
    e.jobId = job.id;
    e.attributes = op.attributes.dup;
    e.checksum = status == EntityStatus.error ? "" : op.checksum;
    e.status = status == EntityStatus.active && attributeValue(op.attributes, "active") == "false"
      ? EntityStatus.inactive : status;
    e.lastOperation = op.operation;
    e.statusMessage = message;
    e.lastSyncAt = nowStdTime();
    e.update(job.updatedBy);
    if (isNew)
      created ~= e;
    else
      changed ~= e;
  }
}
