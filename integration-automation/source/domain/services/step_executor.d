module uim.platform.xyz.domain.services.step_executor;

import domain.types;
import domain.entities.workflow_step;
import domain.entities.execution_log;
// import domain.ports.step_repository;
// import domain.ports.execution_log_repository;
import domain.ports;

import std.uuid;
import std.datetime.systime : Clock;

/// Domain service that handles step execution —
/// completing manual steps, invoking automated steps, recording execution logs.
class StepExecutor
{
  private StepRepository stepRepo;
  private ExecutionLogRepository logRepo;

  this(StepRepository stepRepo, ExecutionLogRepository logRepo)
  {
    this.stepRepo = stepRepo;
    this.logRepo = logRepo;
  }

  /// Mark a manual step as started.
  bool startStep(StepId stepId, TenantId tenantId, UserId executedBy)
  {
    auto step = stepRepo.findById(stepId, tenantId);
    if (step is null)
      return false;
    if (step.status != StepStatus.pending)
      return false;

    step.status = StepStatus.inProgress;
    step.startedAt = Clock.currStdTime();
    stepRepo.update(*step);

    recordLog(step.workflowId, stepId, tenantId, "step.started",
      ExecutionOutcome.success, "Step started", executedBy);
    return true;
  }

  /// Complete a manual step with a result.
  bool completeStep(StepId stepId, TenantId tenantId, UserId executedBy, string result)
  {
    auto step = stepRepo.findById(stepId, tenantId);
    if (step is null)
      return false;
    if (step.status != StepStatus.inProgress)
      return false;

    long startTime = step.startedAt;
    long endTime = Clock.currStdTime();

    step.status = StepStatus.completed;
    step.result = result;
    step.completedAt = endTime;
    stepRepo.update(*step);

    long durationMs = (endTime - startTime) / 10_000; // hnsecs to ms
    recordLog(step.workflowId, stepId, tenantId, "step.completed",
      ExecutionOutcome.success, result, executedBy, durationMs);
    return true;
  }

  /// Mark a step as failed.
  bool failStep(StepId stepId, TenantId tenantId, UserId executedBy, string errorMessage)
  {
    auto step = stepRepo.findById(stepId, tenantId);
    if (step is null)
      return false;

    step.status = StepStatus.failed;
    step.errorMessage = errorMessage;
    step.completedAt = Clock.currStdTime();
    stepRepo.update(*step);

    recordLog(step.workflowId, stepId, tenantId, "step.failed",
      ExecutionOutcome.failure, errorMessage, executedBy);
    return true;
  }

  /// Skip a step.
  bool skipStep(StepId stepId, TenantId tenantId, UserId executedBy, string reason)
  {
    auto step = stepRepo.findById(stepId, tenantId);
    if (step is null)
      return false;

    step.status = StepStatus.skipped;
    step.result = reason;
    step.completedAt = Clock.currStdTime();
    stepRepo.update(*step);

    recordLog(step.workflowId, stepId, tenantId, "step.skipped",
      ExecutionOutcome.skipped, reason, executedBy);
    return true;
  }

  private void recordLog(WorkflowId workflowId, StepId stepId, TenantId tenantId,
    string action, ExecutionOutcome outcome, string message,
    string executedBy, long durationMs = 0)
  {
    auto log = ExecutionLog();
    log.id = randomUUID().toString();
    log.workflowId = workflowId;
    log.stepId = stepId;
    log.tenantId = tenantId;
    log.action = action;
    log.outcome = outcome;
    log.message = message;
    log.executedBy = executedBy;
    log.durationMs = durationMs;
    log.timestamp = Clock.currStdTime();
    logRepo.save(log);
  }
}
