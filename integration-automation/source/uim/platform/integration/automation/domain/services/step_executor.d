/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.services.step_executor;
// import uim.platform.integration.automation.domain.types;
// import uim.platform.integration.automation.domain.entities.workflow_step;
// import uim.platform.integration.automation.domain.entities.execution_log;
// import uim.platform.integration.automation.domain.ports.repositories.steps;
// import uim.platform.integration.automation.domain.ports.repositories.execution_logs;
// import uim.platform.integration.automation.domain.ports;

import uim.platform.integration.automation;

// mixin(ShowModule!());

@safe:
/// Domain service that handles step execution —
/// completing manual steps, invoking automated steps, recording execution logs.
class StepExecutor {
  private StepRepository stepRepo;
  private ExecutionLogRepository logRepo;

  this(StepRepository stepRepo, ExecutionLogRepository logRepo) {
    this.stepRepo = stepRepo;
    this.logRepo = logRepo;
  }

  /// Mark a manual step as started.
  bool startStep(TenantId tenantId, StepId stepId, UserId executedBy) {
    auto step = stepRepo.findById(tenantId, stepId);
    if (step.isNull)
      return false;
    if (step.status != StepStatus.pending)
      return false;

    step.status = StepStatus.inProgress;
    step.startedAt = currentTimestamp();
    stepRepo.update(step);

    recordLog(tenantId, step.workflowId, stepId, "step.started",
        ExecutionOutcome.success, "Step started", executedBy);
    return true;
  }

  /// Complete a manual step with a result.
  bool completeStep(TenantId tenantId, StepId stepId, UserId executedBy, string result) {
    auto step = stepRepo.findById(tenantId, stepId);
    if (step.isNull)
      return false;
    if (step.status != StepStatus.inProgress)
      return false;

    long startTime = step.startedAt;
    long endTime = currentTimestamp();

    step.status = StepStatus.completed;
    step.result = result;
    step.completedAt = endTime;
    stepRepo.update(step);

    long durationMs = (endTime - startTime) / 10_000; // hnsecs to ms
    recordLog(tenantId, step.workflowId, stepId, "step.completed",
        ExecutionOutcome.success, result, executedBy, durationMs);
    return true;
  }

  /// Mark a step as failed.
  bool failStep(TenantId tenantId, StepId stepId, UserId executedBy, string errorMessage) {
    auto step = stepRepo.findById(tenantId, stepId);
    if (step.isNull)
      return false;

    step.status = StepStatus.failed;
    step.errorMessage = errorMessage;
    step.completedAt = currentTimestamp();
    stepRepo.update(step);

    recordLog(tenantId, step.workflowId, stepId, "step.failed",
        ExecutionOutcome.failure, errorMessage, executedBy);
    return true;
  }

  /// Skip a step.
  bool skipStep(TenantId tenantId, StepId stepId, UserId executedBy, string reason) {
    auto step = stepRepo.findById(tenantId, stepId);
    if (step.isNull)
      return false;

    step.status = StepStatus.skipped;
    step.result = reason;
    step.completedAt = currentTimestamp();
    stepRepo.update(step);

    recordLog(tenantId, step.workflowId, stepId, "step.skipped",
        ExecutionOutcome.skipped, reason, executedBy);
    return true;
  }

  private void recordLog(TenantId tenantId, WorkflowId workflowId, StepId stepId, string action,
      ExecutionOutcome outcome, string message, string executedBy, long durationMs = 0) {
    ExecutionLog log;
    log.initEntity(tenantId);

    log.workflowId = workflowId;
    log.stepId = stepId;
    log.tenantId = tenantId;
    log.action = action;
    log.outcome = outcome;
    log.message = message;
    log.executedBy = executedBy;
    log.durationMs = durationMs;
    log.timestamp = log.createdAt;

    logRepo.save(log);
  }
}
