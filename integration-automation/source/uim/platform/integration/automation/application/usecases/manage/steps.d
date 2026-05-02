/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.application.usecases.manage.steps;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.integration.automation.domain.types;
// import uim.platform.integration.automation.domain.entities.workflow_step;

// // import uim.platform.integration.automation.domain.ports.repositories.steps;
// import uim.platform.integration.automation.domain.ports;
// import uim.platform.integration.automation.domain.services.step_executor;
// import uim.platform.integration.automation.domain.services.workflow_engine;
// import uim.platform.integration.automation.application.dto;

import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
class ManageStepsUseCase { // TODO: UIMUseCase {
  private StepRepository repo;
  private StepExecutor executor;
  private WorkflowEngine engine;

  this(StepRepository repo, StepExecutor executor, WorkflowEngine engine) {
    this.repo = repo;
    this.executor = executor;
    this.engine = engine;
  }

  WorkflowStep[] listSteps(TenantId tenantId, WorkflowId workflowId) {
    return repo.findByWorkflow(tenantId, workflowId);
  }

  WorkflowStep getStep(TenantId tenantId, StepId stepId) {
    return repo.findById(tenantId, stepId);
  }

  WorkflowStep[] getMyTasks(TenantId tenantId, UserId userId) {
    return repo.findByAssignee(tenantId, userId);
  }

  WorkflowStep[] getTasksByRole(TenantId tenantId, string role) {
    return repo.findByRole(tenantId, role);
  }

  /// Start a step (mark as in-progress).
  CommandResult startStep(TenantId tenantId, StepId stepId, UserId userId) {
    if (!engine.areDependenciesMet(repo.findById(tenantId, stepId), tenantId))
      return CommandResult(false, "", "Step dependencies are not yet met");

    if (executor.startStep(tenantId, stepId, userId))
      return CommandResult(true, stepId.value, "");
    return CommandResult(false, "", "Cannot start step — not found or not in pending state");
  }

  /// Complete a step and advance the workflow.
  CommandResult completeStep(CompleteStepRequest req) {
    if (req.isNull)
      return CommandResult(false, "", "Step ID is required");
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");

    if (!executor.completeStep(req.tenantId, req.id, req.completedBy, req.result))
      return CommandResult(false, "", "Cannot complete step — not found or not in progress");

    // Try to advance the workflow
    auto step = repo.findById(req.tenantId, req.id);
    if (step !is null)
      engine.advanceWorkflow(step.workflowId, req.tenantId);

    return CommandResult(req.id, "");
  }

  /// Mark a step as failed.
  CommandResult failStep(FailStepRequest req) {
    if (!executor.failStep(req.tenantId, req.id, req.reportedBy, req.errorMessage))
      return CommandResult(false, "", "Cannot fail step — not found");
    return CommandResult(req.id, "");
  }

  /// Skip a step and advance the workflow.
  CommandResult skipStep(SkipStepRequest req) {
    if (!executor.skipStep(req.tenantId, req.id, req.skippedBy, req.reason))
      return CommandResult(false, "", "Cannot skip step — not found");

    auto step = repo.findById(req.tenantId, req.id);
    if (step !is null)
      engine.advanceWorkflow(step.workflowId, req.tenantId);

    return CommandResult(req.id, "");
  }

  /// Assign a step to a user.
  CommandResult assignStep(AssignStepRequest req) {
    auto step = repo.findById(req.tenantId, req.id  );
    if (step.isNull)
      return CommandResult(false, "", "Step not found");

    step.assignedTo = req.assignedTo;
    if (req.assignedRole.length > 0)
      step.assignedRole = req.assignedRole;
    repo.update(step);
    return CommandResult(req.id, "");
  }
}
