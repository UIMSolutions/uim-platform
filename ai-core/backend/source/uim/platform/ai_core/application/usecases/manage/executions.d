/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Executions (AI API /lm/executions): submit, stop, delete, bulk patch.
module uim.platform.ai_core.application.usecases.manage.executions;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

class ManageExecutionsUseCase : AiCoreInteractor, IManageExecutions {
  this(AiCoreRepositories repos, IClock clock, IAiCoreEventPublisher events, LifecyclePolicy policy) {
    super(repos, clock, events, policy);
  }

  Execution createExecution(CreateExecutionRequest r) {
    auto c = configurationOf(r.tenantId, r.resourceGroupId, ConfigurationId(r.configurationId.strip));
    return submit(r.tenantId, r.resourceGroupId, c, r.actor, ScheduleId.init, checkedLabels(r.tags));
  }

  /// Submit an execution of a workflow configuration (also used by schedules).
  Execution submit(TenantId t, ResourceGroupId rg, const Configuration c, UserId actor, ScheduleId schedule, Label[] tags = null) {
    provisionedGroupOf(t, rg);
    auto executable = executableOf(t, rg, c.executableId);
    if (executable.deployable)
      throw AiCoreException.ruleViolation("Executable '" ~ executable.id.value ~ "' is a serving executable; create a deployment instead");
    Execution e;
    stampCreated!(Execution, ExecutionId)(e, t, actor, newResourceId(), now);
    e.resourceGroupId = rg;
    e.configurationId = c.id;
    e.scenarioId = c.scenarioId;
    e.executableId = c.executableId;
    e.scheduleId = schedule;
    e.tags = tags;
    submitExecution(e, now);
    repos.executions.save(e);
    emit("execution.submitted", t, resourceKey(rg.value, e.id.value), Json([
        "configurationId": Json(c.id.value), "scheduleId": Json(schedule.value)
      ]));
    return e;
  }

  Execution patchExecution(PatchExecutionRequest r) {
    auto e = getExecution(r.tenantId, r.resourceGroupId, ExecutionId(r.id));
    auto target = parseDomainEnum!TargetStatus(r.targetStatus, "targetStatus");
    switch (target) {
    case TargetStatus.stopped:
      requestExecutionStop(e, now);
      stampUpdated(e, r.actor, now);
      repos.executions.save(e);
      emit("execution.stopRequested", r.tenantId, resourceKey(r.resourceGroupId.value, e.id.value));
      return e;
    case TargetStatus.deleted:
      deleteExecution(r.tenantId, r.resourceGroupId, e.id);
      e.targetStatus = TargetStatus.deleted;
      return e;
    default:
      throw AiCoreException.invalid("Target status of an execution must be STOPPED or DELETED");
    }
  }

  BulkResult[] patchExecutions(TenantId t, ResourceGroupId rg, UserId actor, const string[] ids, string targetStatus) {
    return bulk(ids, (string id) {
      PatchExecutionRequest r;
      r.tenantId = t;
      r.resourceGroupId = rg;
      r.actor = actor;
      r.id = id;
      r.targetStatus = targetStatus;
      patchExecution(r);
    });
  }

  Execution getExecution(TenantId t, ResourceGroupId rg, ExecutionId id) {
    return required(repos.executions.findById(t, rg, id), "Execution '" ~ id.value ~ "'");
  }

  Execution[] listExecutions(TenantId t, ResourceGroupId rg, RunFilter filter = RunFilter.init) {
    return repos.executions.findByGroup(t, rg).filter!(e => filter.matches(e)).array;
  }

  void deleteExecution(TenantId t, ResourceGroupId rg, ExecutionId id) {
    auto e = getExecution(t, rg, id);
    if (!canDeleteExecution(e))
      throw AiCoreException.ruleViolation("Execution '" ~ id.value ~ "' is " ~ cast(string) e.status ~ "; stop it before deleting");
    repos.metrics.removeByExecution(t, rg, id);
    repos.executions.removeById(t, rg, id);
    emit("execution.deleted", t, resourceKey(rg.value, id.value));
  }
}

/// Run an operation per id and collect AI API style per-item results.
BulkResult[] bulk(const string[] ids, scope void delegate(string) @safe op) {
  BulkResult[] results;
  foreach (id; ids) {
    BulkResult b;
    b.id = id;
    try {
      op(id);
      b.ok = true;
      b.message = "Accepted";
    } catch (AiCoreException e) {
      b.status = e.kind == AiCoreErrorKind.notFound ? 404 : e.kind == AiCoreErrorKind.ruleViolation ? 412 : 400;
      b.message = e.msg;
    }
    results ~= b;
  }
  return results;
}
