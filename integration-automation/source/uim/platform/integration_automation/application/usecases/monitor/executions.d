/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_automation.application.usecases.monitor.executions;

// import uim.platform.integration_automation.domain.entities.execution_log;
// import uim.platform.integration_automation.domain.entities.workflow;
// import uim.platform.integration_automation.domain.entities.workflow_step;
// import uim.platform.integration_automation.domain.ports.repositories.execution_logs;
// import uim.platform.integration_automation.domain.ports.repositories.workflows;
// import uim.platform.integration_automation.domain.ports.repositories.steps;
import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:
class MonitorExecutionsUseCase { // TODO: UIMUseCase {
  private IExecutionLogRepository logRepo;
  private IWorkflowRepository workflowRepo;
  private IStepRepository stepRepo;

  this(IExecutionLogRepository logRepo, IWorkflowRepository workflowRepo, IStepRepository stepRepo) {
    this.logRepo = logRepo;
    this.workflowRepo = workflowRepo;
    this.stepRepo = stepRepo;
  }

  ExecutionLog[] getWorkflowLogs(TenantId tenantId, WorkflowId workflowId) {
    return logRepo.findByWorkflow(tenantId, workflowId);
  }

  ExecutionLog[] getStepLogs(TenantId tenantId, StepId stepId) {
    return logRepo.findByStep(tenantId, stepId);
  }

  ExecutionLog[] getAllLogs(TenantId tenantId) {
    return logRepo.findByTenant(tenantId);
  }

  ExecutionLog[] getFailures(TenantId tenantId) {
    return logRepo.findByOutcome(tenantId, ExecutionOutcome.failure);
  }

  ExecutionLog[] getLogsByTimeRange(TenantId tenantId, long timeFrom, long timeTo) {
    return logRepo.findByTimeRange(tenantId, timeFrom, timeTo);
  }

  /// Get a workflow status summary suitable for a monitoring dashboard.
  WorkflowSummary getWorkflowSummary(TenantId tenantId, WorkflowId workflowId) {
    auto wf = workflowRepo.findById(tenantId, workflowId);
    if (wf.isNull)
      return WorkflowSummary.init;

    auto steps = stepRepo.findByWorkflow(tenantId, workflowId);
    int pending, inProg, completed, failed, skipped;
    foreach (s; steps) {
      final switch (s.status) {
      case StepStatus.pending:
        pending++;
        break;
      case StepStatus.inProgress:
        inProg++;
        break;
      case StepStatus.completed:
        completed++;
        break;
      case StepStatus.failed:
        failed++;
        break;
      case StepStatus.skipped:
        skipped++;
        break;
      case StepStatus.blocked:
        pending++;
        break;
      }
    }

    auto logs = logRepo.findByWorkflow(tenantId, workflowId);

    return WorkflowSummary(wf.id, wf.name, wf.status, wf.totalSteps, completed,
        inProg, pending, failed, skipped, logs.length);
  }
}
/// Summary of workflow progress for monitoring.
struct WorkflowSummary {
  WorkflowId workflowId;
  string workflowName;
  WorkflowStatus status;
  int totalSteps;
  int completedSteps;
  int inProgressSteps;
  int pendingSteps;
  int failedSteps;
  int skippedSteps;
  long totalLogEntries;
}
