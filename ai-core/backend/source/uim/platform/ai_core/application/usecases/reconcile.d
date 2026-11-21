/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The lifecycle reconciler: advances resource groups, executions and
/// deployments according to the LifecyclePolicy, fires due schedules and
/// registers the output artifacts of completed executions.
module uim.platform.ai_core.application.usecases.reconcile;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

class ReconcileLifecycleUseCase : AiCoreInteractor, IReconcileLifecycle {
  protected ManageSchedulesUseCase schedules;

  this(AiCoreRepositories repos, IClock clock, IAiCoreEventPublisher events, LifecyclePolicy policy, ManageSchedulesUseCase schedules) {
    super(repos, clock, events, policy);
    this.schedules = schedules;
  }

  ReconcileResult reconcile(TenantId t) {
    ReconcileResult r;
    auto at = now;

    foreach (g; repos.resourceGroups.findAll(t))
      if (advanceResourceGroup(g, at, policy) == Transition.provisioned) {
        g.updatedAt = at;
        repos.resourceGroups.save(g);
        r.resourceGroupsProvisioned++;
        emit("resourceGroup.provisioned", t, g.id.value);
      }

    foreach (e; repos.executions.findAll(t)) {
      auto tr = advanceExecution(e, at, policy);
      if (tr == Transition.none)
        continue;
      if (tr == Transition.completed)
        r.artifactsCreated += registerOutputs(e, at);
      e.updatedAt = at;
      repos.executions.save(e);
      final switch (tr) {
      case Transition.started:
        r.executionsStarted++;
        emit("execution.running", t, resourceKey(e.resourceGroupId.value, e.id.value));
        break;
      case Transition.completed:
        r.executionsCompleted++;
        emit("execution.completed", t, resourceKey(e.resourceGroupId.value, e.id.value),
          Json(["outputArtifacts": Json(e.outputArtifacts.length)]));
        break;
      case Transition.stopped:
        r.executionsStopped++;
        emit("execution.stopped", t, resourceKey(e.resourceGroupId.value, e.id.value));
        break;
      case Transition.none, Transition.expired, Transition.provisioned:
        break;
      }
    }

    foreach (d; repos.deployments.findAll(t)) {
      auto tr = advanceDeployment(d, at, policy);
      if (tr == Transition.none)
        continue;
      d.updatedAt = at;
      repos.deployments.save(d);
      auto key = resourceKey(d.resourceGroupId.value, d.id.value);
      if (tr == Transition.started) {
        r.deploymentsStarted++;
        emit("deployment.running", t, key, Json(["deploymentUrl": Json(d.deploymentUrl)]));
      } else if (tr == Transition.expired) {
        r.deploymentsExpired++;
        emit("deployment.expired", t, key);
      } else if (tr == Transition.stopped) {
        r.deploymentsStopped++;
        emit("deployment.stopped", t, key);
      }
    }

    foreach (s; repos.schedules.findAll(t)) {
      if (!isScheduleDue(s, at))
        continue;
      try {
        schedules.fire(s, UserId("scheduler"));
        r.schedulesFired++;
      } catch (AiCoreException ex) {
        // keep the schedule but move on to its next slot
        recordScheduleRun(s, ExecutionId.init, at);
        repos.schedules.save(s);
        emit("schedule.failed", t, resourceKey(s.resourceGroupId.value, s.id.value), Json(["error": Json(ex.msg)]));
      }
    }
    return r;
  }

  /// Register one artifact per output slot of the executable.
  protected size_t registerOutputs(ref Execution e, long at) {
    auto executable = repos.executables.findById(e.tenantId, e.resourceGroupId, e.executableId);
    if (executable.isNull)
      return 0;
    size_t created;
    foreach (slot; executable.outputArtifacts) {
      Artifact a;
      stampCreated!(Artifact, ArtifactId)(a, e.tenantId, UserId("runtime"), newResourceId(), at);
      a.resourceGroupId = e.resourceGroupId;
      a.scenarioId = e.scenarioId;
      a.executionId = e.id;
      a.name = executable.id.value ~ "-" ~ slot.key;
      a.kind = slot.kind;
      a.url = "ai://default/" ~ e.resourceGroupId.value ~ "/executions/" ~ e.id.value ~ "/" ~ slot.key;
      a.description = slot.description.length > 0 ? slot.description : "Output '" ~ slot.key ~ "' of execution " ~ e.id.value;
      a.labels = [Label("ext.ai.sap.com/source", "execution")];
      repos.artifacts.save(a);
      e.outputArtifacts ~= ArtifactRef(slot.key, a.id);
      created++;
    }
    return created;
  }
}
