module application.usecases.monitor_executions;

import domain.types;
import domain.entities.execution_log;
import domain.entities.workflow;
import domain.entities.workflow_step;
// import domain.ports.execution_log_repository;
// import domain.ports.workflow_repository;
// import domain.ports.step_repository;
import domain.ports;

class MonitorExecutionsUseCase {
  private ExecutionLogRepository logRepo;
  private WorkflowRepository workflowRepo;
  private StepRepository stepRepo;

  this(ExecutionLogRepository logRepo, WorkflowRepository workflowRepo,
    StepRepository stepRepo) {
    this.logRepo = logRepo;
    this.workflowRepo = workflowRepo;
    this.stepRepo = stepRepo;
  }

  ExecutionLog[] getWorkflowLogs(WorkflowId workflowId, TenantId tenantId) {
    return logRepo.findByWorkflow(workflowId, tenantId);
  }

  ExecutionLog[] getStepLogs(StepId stepId, TenantId tenantId) {
    return logRepo.findByStep(stepId, tenantId);
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
  WorkflowSummary getWorkflowSummary(WorkflowId workflowId, TenantId tenantId) {
    auto wf = workflowRepo.findById(workflowId, tenantId);
    if (wf is null)
      return WorkflowSummary.init;

    auto steps = stepRepo.findByWorkflow(workflowId, tenantId);
    int pending, inProg, completed, failed, skipped;
    foreach (ref s; steps) {
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

    auto logs = logRepo.findByWorkflow(workflowId, tenantId);

    return WorkflowSummary(
      wf.id, wf.name, wf.status,
      wf.totalSteps, completed, inProg, pending, failed, skipped,
      cast(long)logs.length
    );
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
