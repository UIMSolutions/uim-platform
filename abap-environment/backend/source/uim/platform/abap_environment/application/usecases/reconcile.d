/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.reconcile;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Interactor: one reconciliation pass over a tenant (the simulated ABAP
/// landscape). Every call advances each transitional object by one step:
///
///   systems     provisioning → active, updating → active, deleting → removed (cascade)
///   components  cloning → cloned, pulling → cloned          (only in active systems)
///   transports  importing → imported | error                 (waits for an active target)
///   jobs        due & scheduled → running → completed | failed (recurring: → scheduled)
class ReconcileUseCase : IReconcileUseCase {
  protected AbapRepositories repos;
  protected CascadeDeleter cascade;
  protected IAbapLandscapeGateway landscape;
  protected IAbapEventPublisher publisher;

  /// Maximum number of commits kept per software component.
  enum size_t maxCommitHistory = 50;

  this(AbapRepositories repos, CascadeDeleter cascade, IAbapLandscapeGateway landscape, IAbapEventPublisher publisher) {
    this.repos = repos;
    this.cascade = cascade;
    this.landscape = landscape;
    this.publisher = publisher;
  }

  ReconcileReport reconcile(TenantId tenantId) {
    ReconcileReport report;
    report.tenantId = tenantId;
    auto now = nowStdTime();

    foreach (system; repos.systems.findByTenant(tenantId)) {
      report.examined++;
      reconcileSystem(report, system, now);
    }
    foreach (c; repos.softwareComponents.findByTenant(tenantId)) {
      report.examined++;
      reconcileComponent(report, c, now);
    }
    foreach (t; repos.transportRequests.findByTenant(tenantId)) {
      report.examined++;
      reconcileTransport(report, t, now);
    }
    foreach (j; repos.applicationJobs.findByTenant(tenantId)) {
      report.examined++;
      reconcileJob(report, j, now);
    }
    return report;
  }

  protected void note(ref ReconcileReport report, string change, string topic, Json payload) {
    report.advanced++;
    report.changes ~= change;
    publisher.publish(topic, payload);
  }

  protected static Json event(TEntity)(const TEntity e) {
    return Json.emptyObject.set("tenantId", e.tenantId.value).set("id", e.id.value).set("name", e.name);
  }

  protected void reconcileSystem(ref ReconcileReport report, SystemInstance s, long now) {
    final switch (s.status) {
    case SystemStatus.provisioning:
      auto provisioned = landscape.provision(s);
      s.serviceUrl = provisioned.serviceUrl;
      s.webSocketUrl = provisioned.webSocketUrl;
      if (provisioned.stackVersion.length > 0)
        s.stackVersion = provisioned.stackVersion;
      transitionTo(s, SystemStatus.active);
      s.activatedAt = now;
      s.statusMessage = "";
      s.update();
      repos.systems.update(s);
      note(report, "System " ~ s.name ~ " (" ~ s.sapSystemId ~ "): provisioned", "abap.system.activated", event(s));
      break;
    case SystemStatus.updating:
      transitionTo(s, SystemStatus.active);
      s.statusMessage = "";
      s.update();
      repos.systems.update(s);
      note(report, "System " ~ s.name ~ ": update finished (" ~ s.softwareVersion ~ ")", "abap.system.updated", event(s));
      break;
    case SystemStatus.deleting:
      auto removed = cascade.clearSystem(s.tenantId, s.id);
      landscape.deprovision(s);
      repos.systems.remove(s);
      note(report, "System " ~ s.name ~ ": deprovisioned (" ~ removed.to!string ~ " object(s) deleted)",
        "abap.system.deleted", event(s));
      break;
    case SystemStatus.active, SystemStatus.suspended, SystemStatus.error:
      break;
    }
  }

  protected bool systemActive(TenantId tenantId, SystemInstanceId id) {
    auto s = repos.systems.findById(tenantId, id);
    return !s.isNull && s.status == SystemStatus.active;
  }

  protected void reconcileComponent(ref ReconcileReport report, SoftwareComponent c, long now) {
    if (c.status != ComponentStatus.cloning && c.status != ComponentStatus.pulling)
      return;
    if (!systemActive(c.tenantId, c.systemInstanceId))
      return;

    auto cloning = c.status == ComponentStatus.cloning;
    auto head = landscape.headCommit(c.repositoryUrl, c.branch);
    if (head.length == 0) {
      c.status = ComponentStatus.error;
      c.statusMessage = "Branch '" ~ c.branch ~ "' of " ~ c.repositoryUrl ~ " cannot be read";
      c.update();
      repos.softwareComponents.update(c);
      note(report, "Software component " ~ c.name ~ ": " ~ c.statusMessage, "abap.software-component.failed", event(c));
      return;
    }

    auto changed = head != c.currentCommitId;
    if (changed) {
      c.commitHistory ~= ComponentCommit(head, c.branch, cloning ? "Clone of " ~ c.branch : "Pull of " ~ c.branch,
        c.clonedBy.isEmpty ? "system" : c.clonedBy.value, now);
      if (c.commitHistory.length > maxCommitHistory)
        c.commitHistory = c.commitHistory[$ - maxCommitHistory .. $];
      c.currentCommitId = head;
    }
    c.status = ComponentStatus.cloned;
    c.statusMessage = changed ? "" : "Already up to date";
    if (cloning)
      c.clonedAt = now;
    else
      c.lastPulledAt = now;
    c.update();
    repos.softwareComponents.update(c);
    note(report, "Software component " ~ c.name ~ ": " ~ (cloning ? "cloned" : "pulled") ~ " at " ~ head,
      "abap.software-component." ~ (cloning ? "cloned" : "pulled"), event(c));
  }

  protected void reconcileTransport(ref ReconcileReport report, TransportRequest t, long now) {
    if (t.status != TransportStatus.importing)
      return;
    auto target = repos.systems.findById(t.tenantId, t.targetSystemId);
    if (target.isNull) {
      t.status = TransportStatus.error;
      t.statusMessage = "Target system no longer exists";
    } else if (target.status != SystemStatus.active) {
      return; // wait until the target system is available again
    } else {
      auto error = landscape.importTransport(t, target);
      if (error.length == 0) {
        t.status = TransportStatus.imported;
        t.importedAt = now;
        t.statusMessage = "Imported into " ~ target.name;
      } else {
        t.status = TransportStatus.error;
        t.statusMessage = error;
      }
    }
    t.update();
    repos.transportRequests.update(t);
    note(report, "Transport " ~ t.name ~ ": " ~ enumText(t.status) ~ (t.statusMessage.length ? " — " ~ t.statusMessage : ""),
      "abap.transport-request." ~ enumText(t.status), event(t));
  }

  protected void reconcileJob(ref ReconcileReport report, ApplicationJob job, long now) {
    if (job.status == JobStatus.scheduled && job.active && job.scheduledAt <= now) {
      if (!systemActive(job.tenantId, job.systemInstanceId))
        return;
      startRun(job, now);
      job.update();
      repos.applicationJobs.update(job);
      note(report, "Application job " ~ job.name ~ ": started", "abap.application-job.started", event(job));
      return;
    }
    if (job.status != JobStatus.running)
      return;

    auto outcome = landscape.runJob(job);
    auto ok = outcome.returnCode == 0;
    if (job.executionHistory.length > 0) {
      job.executionHistory[$ - 1].status = ok ? JobStatus.completed : JobStatus.failed;
      job.executionHistory[$ - 1].finishedAt = now;
      job.executionHistory[$ - 1].returnCode = outcome.returnCode;
      job.executionHistory[$ - 1].message = outcome.message;
    }
    job.runCount++;
    job.lastRunAt = now;
    auto next = job.active ? nextRun(job.frequency, max(now, job.scheduledAt)) : 0;
    if (next > 0) {
      job.status = JobStatus.scheduled;
      job.scheduledAt = next;
    } else
      job.status = ok ? JobStatus.completed : JobStatus.failed;
    job.update();
    repos.applicationJobs.update(job);
    note(report, "Application job " ~ job.name ~ ": run " ~ (ok ? "completed" : "failed (rc " ~ outcome.returnCode.to!string ~ ")")
        ~ (next > 0 ? ", next run " ~ displayTime(next) : ""), "abap.application-job." ~ (ok ? "completed" : "failed"), event(job));
  }
}
