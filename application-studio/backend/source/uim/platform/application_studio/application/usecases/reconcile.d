/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.reconcile;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Interactor: one reconciliation pass over a tenant (the simulated workspace
/// runtime). Every call advances each transitional object by one step:
///
///   dev spaces  starting|resuming → running | error, stopping → stopped,
///               hibernating → hibernated, idle running → hibernating,
///               deleting → removed (cascade)
///   bindings    connecting → connected | error          (dev space running)
///   runs        starting → running | error              (dev space running)
///   builds      building → succeeded | failed, deploying → deployed | failed
class ReconcileUseCase : IReconcileUseCase {
  protected StudioRepositories repos;
  protected CascadeDeleter cascade;
  protected ProjectStatusSync projectStatus;
  protected IWorkspaceGateway workspace;
  protected IStudioEventPublisher publisher;

  this(StudioRepositories repos, CascadeDeleter cascade, ProjectStatusSync projectStatus,
      IWorkspaceGateway workspace, IStudioEventPublisher publisher) {
    this.repos = repos;
    this.cascade = cascade;
    this.projectStatus = projectStatus;
    this.workspace = workspace;
    this.publisher = publisher;
  }

  ReconcileReport reconcile(TenantId tenantId) {
    ReconcileReport report;
    report.tenantId = tenantId;
    auto now = nowStdTime();

    foreach (ds; repos.devSpaces.findByTenant(tenantId)) {
      report.examined++;
      reconcileDevSpace(report, ds, now);
    }
    foreach (b; repos.serviceBindings.findByTenant(tenantId)) {
      report.examined++;
      reconcileBinding(report, b, now);
    }
    foreach (r; repos.runConfigurations.findByTenant(tenantId)) {
      report.examined++;
      reconcileRun(report, r, now);
    }
    foreach (b; repos.buildConfigurations.findByTenant(tenantId)) {
      report.examined++;
      reconcileBuild(report, b, now);
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

  protected bool devSpaceRunning(TenantId tenantId, DevSpaceId id) {
    auto ds = repos.devSpaces.findById(tenantId, id);
    return !ds.isNull && ds.status == DevSpaceStatus.running;
  }

  /// Stop the live runs of a dev space that goes down. Returns how many were stopped.
  protected size_t stopRuns(const DevSpace ds, string reason) {
    size_t stopped;
    foreach (r; repos.runConfigurations.findByDevSpace(ds.tenantId, ds.id)) {
      if (!r.status.isLive)
        continue;
      workspace.stopRun(r);
      r.status = RunStatus.stopped;
      r.statusMessage = reason;
      r.url = "";
      r.update();
      repos.runConfigurations.update(r);
      stopped++;
    }
    return stopped;
  }

  protected void reconcileDevSpace(ref ReconcileReport report, DevSpace ds, long now) {
    auto topic = "studio.dev-space.";
    switch (ds.status) {
    case DevSpaceStatus.starting, DevSpaceStatus.resuming:
      auto resumed = ds.status == DevSpaceStatus.resuming;
      auto outcome = workspace.startDevSpace(ds);
      if (outcome.ok) {
        transitionTo(ds, DevSpaceStatus.running);
        ds.url = outcome.url;
        ds.startedAt = now;
        ds.lastAccessedAt = now;
        ds.statusMessage = "";
      } else {
        transitionTo(ds, DevSpaceStatus.error);
        ds.statusMessage = outcome.error;
      }
      save(ds);
      note(report, "Dev space " ~ ds.name ~ ": " ~ (outcome.ok ? (resumed ? "resumed" : "running") : "failed — " ~ outcome.error),
        topic ~ (outcome.ok ? "running" : "failed"), event(ds));
      break;
    case DevSpaceStatus.stopping:
      workspace.stopDevSpace(ds);
      auto runs = stopRuns(ds, "Dev space stopped");
      transitionTo(ds, DevSpaceStatus.stopped);
      ds.url = "";
      ds.statusMessage = "";
      save(ds);
      note(report, "Dev space " ~ ds.name ~ ": stopped" ~ (runs ? " (" ~ runs.to!string ~ " run(s) ended)" : ""),
        topic ~ "stopped", event(ds));
      break;
    case DevSpaceStatus.hibernating:
      workspace.hibernateDevSpace(ds);
      stopRuns(ds, "Dev space hibernated");
      transitionTo(ds, DevSpaceStatus.hibernated);
      ds.url = "";
      save(ds);
      note(report, "Dev space " ~ ds.name ~ ": hibernated", topic ~ "hibernated", event(ds));
      break;
    case DevSpaceStatus.deleting:
      auto removed = cascade.clearDevSpace(ds.tenantId, ds.id);
      workspace.deleteDevSpace(ds);
      repos.devSpaces.remove(ds);
      note(report, "Dev space " ~ ds.name ~ ": deleted (" ~ removed.to!string ~ " object(s) removed)",
        topic ~ "deleted", event(ds));
      break;
    case DevSpaceStatus.running:
      if (!isIdle(ds, now))
        break;
      transitionTo(ds, DevSpaceStatus.hibernating);
      ds.statusMessage = "Idle for " ~ ds.hibernateAfterDays.to!string ~ " day(s)";
      save(ds);
      note(report, "Dev space " ~ ds.name ~ ": hibernating after inactivity", topic ~ "hibernating", event(ds));
      break;
    default:
      break;
    }
  }

  protected void save(ref DevSpace ds) {
    ds.update();
    repos.devSpaces.update(ds);
  }

  protected void reconcileBinding(ref ReconcileReport report, ServiceBinding b, long now) {
    if (b.status != BindingStatus.connecting || !devSpaceRunning(b.tenantId, b.devSpaceId))
      return;
    auto outcome = workspace.testConnection(b);
    b.status = outcome.ok ? BindingStatus.connected : BindingStatus.error;
    b.statusMessage = outcome.ok ? outcome.message : outcome.error;
    if (outcome.ok)
      b.connectedAt = now;
    b.update();
    repos.serviceBindings.update(b);
    note(report, "Service binding " ~ b.name ~ ": " ~ enumText(b.status) ~ (outcome.ok ? "" : " — " ~ outcome.error),
      "studio.service-binding." ~ enumText(b.status), event(b));
  }

  protected void reconcileRun(ref ReconcileReport report, RunConfiguration r, long now) {
    if (r.status != RunStatus.starting)
      return;
    auto ds = repos.devSpaces.findById(r.tenantId, r.devSpaceId);
    if (ds.isNull) {
      r.status = RunStatus.error;
      r.statusMessage = "Dev space no longer exists";
    } else if (ds.status != DevSpaceStatus.running) {
      return; // wait until the dev space runs again
    } else {
      auto outcome = workspace.startRun(r, ds);
      if (outcome.ok) {
        r.status = RunStatus.running;
        r.url = outcome.url;
        r.lastRunAt = now;
        r.runCount++;
        r.statusMessage = "";
      } else {
        r.status = RunStatus.error;
        r.statusMessage = outcome.error;
      }
    }
    r.update();
    repos.runConfigurations.update(r);
    note(report, "Run configuration " ~ r.name ~ ": " ~ enumText(r.status) ~ (r.url.length ? " at " ~ r.url : "")
        ~ (r.status == RunStatus.error ? " — " ~ r.statusMessage : ""), "studio.run-configuration." ~ enumText(r.status), event(r));
  }

  protected void reconcileBuild(ref ReconcileReport report, BuildConfiguration bc, long now) {
    if (!bc.status.isBusy)
      return;
    auto project = repos.projects.findById(bc.tenantId, bc.projectId);
    auto deploying = bc.status == BuildStatus.deploying;
    WorkspaceOutcome outcome;
    if (project.isNull)
      outcome.error = "Project no longer exists";
    else
      outcome = deploying ? workspace.deploy(bc, project) : workspace.build(bc, project);

    if (outcome.ok) {
      if (deploying) {
        bc.status = BuildStatus.deployed;
        bc.lastDeployAt = now;
      } else {
        bc.status = BuildStatus.succeeded;
        bc.lastArtifact = outcome.artifact;
        bc.lastBuildAt = now;
      }
      bc.statusMessage = outcome.message;
    } else {
      bc.status = BuildStatus.failed;
      bc.statusMessage = outcome.error;
    }
    if (bc.history.length > 0) {
      bc.history[$ - 1].status = bc.status;
      bc.history[$ - 1].finishedAt = now;
      bc.history[$ - 1].artifact = outcome.ok ? outcome.artifact : "";
      bc.history[$ - 1].message = bc.statusMessage;
    }
    bc.update();
    repos.buildConfigurations.update(bc);
    projectStatus.sync(bc.tenantId, bc.projectId);
    note(report, "Build configuration " ~ bc.name ~ " (" ~ bc.projectName ~ "): " ~ enumText(bc.status)
        ~ (bc.statusMessage.length ? " — " ~ bc.statusMessage : ""), "studio.build-configuration." ~ enumText(bc.status), event(bc));
  }
}
