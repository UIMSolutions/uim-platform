/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Reconciliation with the AI runtimes (the reconcile worker, the
/// "Reconcile" action and the CLI): poll the active executions and
/// deployments, apply the reported transitions, stop deployments at the end
/// of their time to live. Everything is written in one batch.
module uim.platform.ai_launchpad.application.usecases.reconcile;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class ReconcileRuntimeUseCase : AilpInteractor, IReconcileRuntime {
  protected IAiRuntime runtime;

  this(AilpRepositories repos, IClock clock, IAuditTrail audit, IAilpUnitOfWork unitOfWork, AilpPolicy policy, IAiRuntime runtime) {
    super(repos, clock, audit, unitOfWork, policy);
    this.runtime = runtime;
  }

  ReconcileSummary reconcile(TenantId t, UserId actor) {
    ReconcileSummary s;
    Connection[string] connections;
    Configuration[string] configurations;
    foreach (c; repos.connections.findAll(t))
      connections[c.id.value] = c;
    foreach (c; repos.configurations.findAll(t))
      configurations[c.id.value] = c;
    auto at = now;
    batch(() {
      foreach (e; repos.executions.findAll(t).filter!(x => x.isActive)) {
        if (s.checked >= policy.maxReconcileBatch)
          break;
        s.checked++;
        reconcileExecution(t, e, connections, configurations, at, s);
      }
      foreach (d; repos.deployments.findAll(t).filter!(x => x.isActive)) {
        if (s.checked >= policy.maxReconcileBatch)
          break;
        s.checked++;
        reconcileDeployment(t, d, connections, configurations, at, s);
      }
    });
    if (s.changes > 0)
      emit("runtime.reconciled", t, actor, t.value, Json(["summary": Json(s.summary)]));
    return s;
  }

  protected void reconcileExecution(TenantId t, Execution e, Connection[string] connections,
    Configuration[string] configurations, long at, ref ReconcileSummary s) {
    auto c = e.connectionId.value in connections;
    auto cfg = e.configurationId.value in configurations;
    if (c is null || cfg is null || !c.isActive)
      return; // runtime not reachable: try again later
    auto state = runtime.pollExecution(*c, *cfg, e, at);
    auto target = domainEnumOr!ExecutionStatus(state.status, e.status);
    if (target == e.status)
      return;
    if (e.status == ExecutionStatus.pending && target != ExecutionStatus.pending) {
      e.start(at);
      s.started++;
      emit("execution.started", t, UserId(systemActor), e.id.value);
    }
    if (e.status == ExecutionStatus.running && (target == ExecutionStatus.completed || target == ExecutionStatus.failed)) {
      e.complete(at, target == ExecutionStatus.completed, state.message);
      if (target == ExecutionStatus.completed)
        s.completed++;
      else {
        s.failed++;
        s.messages ~= "execution " ~ e.id.value ~ ": " ~ state.message;
      }
      emit(target == ExecutionStatus.completed ? "execution.completed" : "execution.failed", t, UserId(systemActor),
        e.id.value, Json(["durationSeconds": Json(e.durationSeconds), "message": Json(state.message)]));
    } else if (target == ExecutionStatus.stopped && e.isActive) {
      e.stop(at, "the runtime");
    }
    stampUpdated(e, UserId(systemActor), at);
    repos.executions.save(e);
  }

  protected void reconcileDeployment(TenantId t, Deployment d, Connection[string] connections,
    Configuration[string] configurations, long at, ref ReconcileSummary s) {
    if (d.isExpiredAt(at)) {
      d.stop(at, format("Time to live of %d minutes reached", d.ttlMinutes));
      s.expired++;
      emit("deployment.expired", t, UserId(systemActor), d.id.value);
      stampUpdated(d, UserId(systemActor), at);
      repos.deployments.save(d);
      return;
    }
    auto c = d.connectionId.value in connections;
    auto cfg = d.configurationId.value in configurations;
    if (c is null || cfg is null || !c.isActive)
      return;
    auto state = runtime.pollDeployment(*c, *cfg, d, at);
    auto target = domainEnumOr!DeploymentStatus(state.status, d.status);
    if (target == d.status)
      return;
    if (d.status == DeploymentStatus.pending && target == DeploymentStatus.running) {
      d.markRunning(at, state.url);
      s.deployed++;
      emit("deployment.running", t, UserId(systemActor), d.id.value, Json(["url": Json(state.url)]));
    } else if (target == DeploymentStatus.dead) {
      d.markDead(state.message);
      s.dead++;
      s.messages ~= "deployment " ~ d.id.value ~ ": " ~ state.message;
      emit("deployment.dead", t, UserId(systemActor), d.id.value, Json(["message": Json(state.message)]));
    } else if (target == DeploymentStatus.stopped && d.isActive) {
      d.stop(at, state.message.length ? state.message : "Stopped by the runtime");
    } else
      return;
    stampUpdated(d, UserId(systemActor), at);
    repos.deployments.save(d);
  }
}
