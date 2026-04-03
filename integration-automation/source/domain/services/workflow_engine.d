module uim.platform.xyz.domain.services.workflow_engine;

import domain.types;
import domain.entities.workflow;
import domain.entities.workflow_step;
// import domain.ports.workflow_repository;
// import domain.ports.step_repository;
import domain.ports;

/// Domain service that orchestrates workflow progression —
/// advances to the next step, checks dependencies, and updates status.
class WorkflowEngine
{
  private WorkflowRepository workflowRepo;
  private StepRepository stepRepo;

  this(WorkflowRepository workflowRepo, StepRepository stepRepo)
  {
    this.workflowRepo = workflowRepo;
    this.stepRepo = stepRepo;
  }

  /// Check if all dependencies of a step are satisfied.
  bool areDependenciesMet(WorkflowStep step, TenantId tenantId)
  {
    if (step.dependencies.length == 0)
      return true;

    foreach (depId; step.dependencies)
    {
      auto dep = stepRepo.findById(depId, tenantId);
      if (dep is null || dep.status != StepStatus.completed)
        return false;
    }
    return true;
  }

  /// Advance the workflow to the next pending step if possible.
  bool advanceWorkflow(WorkflowId workflowId, TenantId tenantId)
  {
    auto wf = workflowRepo.findById(workflowId, tenantId);
    if (wf is null || wf.status != WorkflowStatus.inProgress)
      return false;

    auto steps = stepRepo.findByWorkflow(workflowId, tenantId);
    if (steps.length == 0)
      return false;

    // Count completed
    int completed = 0;
    foreach (ref s; steps)
      if (s.status == StepStatus.completed || s.status == StepStatus.skipped)
        completed++;

    wf.completedSteps = completed;

    // All steps done?
    if (completed >= wf.totalSteps)
    {
      import std.datetime.systime : Clock;
      wf.status = WorkflowStatus.completed;
      wf.completedAt = Clock.currStdTime();
      workflowRepo.update(*wf);
      return true;
    }

    // Find next pending step whose dependencies are met
    import std.algorithm : sort;
    import std.array : array;
    auto sorted = steps.dup;
    sorted.sort!((a, b) => a.sequenceNumber < b.sequenceNumber);

    foreach (ref s; sorted)
    {
      if (s.status == StepStatus.pending && areDependenciesMet(s, tenantId))
      {
        wf.currentStepIndex = s.sequenceNumber;
        workflowRepo.update(*wf);
        return true;
      }
    }

    workflowRepo.update(*wf);
    return false;
  }

  /// Check if the active workflow limit for a tenant is reached (SAP limit: 15).
  bool isWorkflowLimitReached(TenantId tenantId)
  {
    return workflowRepo.countActiveByTenant(tenantId) >= 15;
  }
}
