/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Workflows: instantiation from active scenarios and the lifecycle.
///
/// Rules: only active scenarios with task templates are instantiated; at
/// most maxOpenWorkflows open workflows per tenant (SAP limit: 15); source
/// and target systems must exist, differ and match the system types of the
/// scenario, and are required if a template needs them; only planned or
/// finished workflows can be deleted (the execution log is kept).
module uim.platform.integration_automation.application.usecases.workflows;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

class ManageWorkflowsUseCase : IaInteractor, IManageWorkflows {
  protected IProcessTasks tasks; /// runs the automation after start/resume

  this(IaRepositories repos, IClock clock, IIaEventPublisher events, IIaUnitOfWork unitOfWork, IaPolicy policy,
    IProcessTasks tasks) {
    super(repos, clock, events, unitOfWork, policy);
    this.tasks = tasks;
  }

  Workflow create(CreateWorkflowCommand c) {
    auto t = c.tenantId;
    auto id = idOrNew(c.id, "Workflow ID");
    if (repos.workflows.existsById(t, WorkflowId(id)))
      throw IaException.conflict("Workflow '" ~ id ~ "' already exists");
    if (c.scenarioId.strip.length == 0)
      throw IaException.invalid("Scenario is required");
    auto scenario = required(repos.scenarios.findById(t, ScenarioId(c.scenarioId.strip)), "Scenario '" ~ c.scenarioId ~ "'");
    if (!scenario.isActive)
      throw IaException.ruleViolation("Scenario '" ~ scenario.id.value ~ "' is " ~ cast(string) scenario.status
          ~ " — workflows can only be created from active scenarios");
    auto templates = repos.scenarioTasks.findByReference(t, "scenarioId", scenario.id.value);
    if (templates.length == 0)
      throw IaException.ruleViolation("Scenario '" ~ scenario.id.value ~ "' has no task templates");
    auto open = repos.workflows.findAll(t).count!(w => w.isOpen);
    if (policy.maxOpenWorkflows > 0 && open >= policy.maxOpenWorkflows)
      throw IaException.ruleViolation(format("The limit of %d open workflows per tenant is reached — complete or "
          ~ "terminate a workflow first", policy.maxOpenWorkflows));

    auto source = systemFor(t, c.sourceSystemId, scenario.sourceSystemType, templates.any!(x => x.requiresSourceSystem), "Source");
    auto target = systemFor(t, c.targetSystemId, scenario.targetSystemType, templates.any!(x => x.requiresTargetSystem), "Target");
    if (!source.isNull && source == target)
      throw IaException.invalid("Source and target system must differ");

    Workflow wf;
    stampCreated!(Workflow, WorkflowId)(wf, t, c.actor, id, now);
    wf.scenarioId = scenario.id;
    wf.scenarioVersion = scenario.version_;
    wf.name = c.name.strip.length ? c.name.strip : scenario.name;
    wf.description = c.description.strip.length ? c.description.strip : scenario.description;
    wf.sourceSystemId = source;
    wf.targetSystemId = target;
    wf.validate();

    auto planned = planTasks(templates, t, wf.id, source, target, () => newResourceId());
    foreach (ref task; planned) {
      task.createdAt = wf.createdAt;
      task.updatedAt = wf.createdAt;
      task.createdBy = c.actor;
      task.updatedBy = c.actor;
      task.validate();
    }
    wf.apply(progressOf(planned), now);
    batch(() {
      repos.workflows.save(wf);
      foreach (task; planned)
        repos.workflowTasks.save(task);
      record(t, wf.id, WorkflowTaskId.init, "workflow.created", ExecutionOutcome.info,
        format("Workflow '%s' created from scenario '%s' %s with %d tasks", wf.name, scenario.name, scenario.version_,
        planned.length), c.actor.value);
    });
    return c.start ? start(t, wf.id, c.actor) : wf;
  }

  Workflow update(UpdateWorkflowCommand c) {
    auto wf = get(c.tenantId, WorkflowId(c.id));
    if (c.name.isSet)
      wf.name = c.name.value.strip;
    if (c.description.isSet)
      wf.description = c.description.value.strip;
    wf.validate();
    stampUpdated(wf, c.actor, now);
    repos.workflows.save(wf);
    emit("workflow.updated", c.tenantId, wf.id.value);
    return wf;
  }

  Workflow get(TenantId t, WorkflowId id) {
    return workflowOf(t, id);
  }

  Workflow[] list(TenantId t) {
    return repos.workflows.findAll(t);
  }

  void remove(TenantId t, WorkflowId id, UserId actor) {
    auto wf = get(t, id);
    if (wf.status != WorkflowStatus.planned && wf.isOpen)
      throw IaException.ruleViolation("Workflow '" ~ id.value ~ "' is " ~ cast(string) wf.status
          ~ " — terminate it before deleting it");
    batch(() {
      foreach (task; repos.workflowTasks.findByReference(t, "workflowId", id.value))
        repos.workflowTasks.removeById(t, task.id);
      repos.workflows.removeById(t, id);
      record(t, id, WorkflowTaskId.init, "workflow.deleted", ExecutionOutcome.info,
        "Workflow '" ~ wf.name ~ "' deleted", actor.value);
    });
  }

  Workflow start(TenantId t, WorkflowId id, UserId actor) {
    auto wf = get(t, id);
    wf.start(now);
    batch(() {
      wf = refreshWorkflow(t, wf, actor);
      record(t, id, WorkflowTaskId.init, "workflow.started", ExecutionOutcome.info, "Workflow '" ~ wf.name ~ "' started",
        actor.value);
    });
    return automate(t, wf, actor);
  }

  Workflow suspend(TenantId t, WorkflowId id, UserId actor) {
    auto wf = get(t, id);
    wf.suspend();
    stampUpdated(wf, actor, now);
    batch(() {
      repos.workflows.save(wf);
      record(t, id, WorkflowTaskId.init, "workflow.suspended", ExecutionOutcome.info, "Workflow '" ~ wf.name ~ "' suspended",
        actor.value);
    });
    return wf;
  }

  Workflow resume(TenantId t, WorkflowId id, UserId actor) {
    auto wf = get(t, id);
    wf.resume();
    batch(() {
      wf = refreshWorkflow(t, wf, actor);
      record(t, id, WorkflowTaskId.init, "workflow.resumed", ExecutionOutcome.info, "Workflow '" ~ wf.name ~ "' resumed",
        actor.value);
    });
    return automate(t, wf, actor);
  }

  Workflow terminate(TenantId t, WorkflowId id, string reason, UserId actor) {
    auto wf = get(t, id);
    wf.terminate(reason, now);
    stampUpdated(wf, actor, now);
    batch(() {
      repos.workflows.save(wf);
      record(t, id, WorkflowTaskId.init, "workflow.terminated", ExecutionOutcome.info,
        "Workflow '" ~ wf.name ~ "' terminated" ~ (wf.terminationReason.length ? ": " ~ wf.terminationReason : ""), actor.value);
    });
    return wf;
  }

  /// Run ready automated tasks right away if configured (no worker).
  protected Workflow automate(TenantId t, Workflow wf, UserId actor) {
    if (policy.runAutomationImmediately && wf.status == WorkflowStatus.inProgress && tasks !is null) {
      tasks.runAutomation(t, actor, wf.id);
      return get(t, wf.id);
    }
    return wf;
  }

  /// The system of a workflow role: existing, of the required type.
  protected SystemConnectionId systemFor(TenantId t, string id, SystemType required_, bool needed, string role) {
    auto v = id.strip;
    if (v.length == 0) {
      if (needed)
        throw IaException.invalid(role ~ " system is required by the task templates of the scenario");
      return SystemConnectionId.init;
    }
    auto s = required(repos.systems.findById(t, SystemConnectionId(v)), role ~ " system '" ~ v ~ "'");
    if (required_ != SystemType.any_ && s.systemType != required_)
      throw IaException.ruleViolation(format("%s system '%s' is of type %s, the scenario needs %s", role, v,
          cast(string) s.systemType, cast(string) required_));
    return s.id;
  }
}
