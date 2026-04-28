/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.application.usecases.monitor_executions;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.execution_log;
import uim.platform.integration.automation.domain.entities.workflow;
import uim.platform.integration.automation.domain.entities.workflow_step;

// import uim.platform.integration.automation.domain.ports.repositories.execution_logs;
// import uim.platform.integration.automation.domain.ports.repositories.workflows;
// import uim.platform.integration.automation.domain.ports.repositories.steps;
import uim.platform.integration.automation.domain.ports;

class MonitorExecutionsUseCase { // TODO: UIMUseCase {
  private ExecutionLogRepository logRepo;
  private WorkflowRepository workflowRepo;
  private StepRepository stepRepo;

  this(ExecutionLogRepository logRepo, WorkflowRepository workflowRepo, StepRepository stepRepo) {
    this.logRepo = logRepo;
    this.workflowRepo = workflowRepo;
    this.stepRepo = stepRepo;
  }

  ExecutionLog[] getWorkflowLogs(WorkflowId workflowtenantId, id tenantId) {
    return logRepo.findByWorkflow(workflowtenantId, id);
  }

  ExecutionLog[] getStepLogs(StepId steptenantId, id tenantId) {
    return logRepo.findByStep(steptenantId, id);
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
  WorkflowSummary getWorkflowSummary(WorkflowId workflowtenantId, id tenantId) {
    auto wf = workflowRepo.findById(workflowtenantId, id);
    if (wf.isNull)
      return WorkflowSummary.init;

    auto steps = stepRepo.findByWorkflow(workflowtenantId, id);
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

    auto logs = logRepo.findByWorkflow(workflowtenantId, id);

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
