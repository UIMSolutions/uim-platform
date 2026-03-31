module domain.ports.step_repository;

import domain.types;
import domain.entities.workflow_step;

/// Port for persisting and querying workflow steps.
interface StepRepository
{
  WorkflowStep[] findByWorkflow(WorkflowId workflowId, TenantId tenantId);
  WorkflowStep* findById(StepId id, TenantId tenantId);
  WorkflowStep[] findByAssignee(TenantId tenantId, UserId assignedTo);
  WorkflowStep[] findByRole(TenantId tenantId, string assignedRole);
  WorkflowStep[] findByStatus(WorkflowId workflowId, TenantId tenantId, StepStatus status);
  WorkflowStep* findBySequence(WorkflowId workflowId, TenantId tenantId, int sequenceNumber);
  void save(WorkflowStep step);
  void update(WorkflowStep step);
  void remove(StepId id, TenantId tenantId);
  void removeByWorkflow(WorkflowId workflowId, TenantId tenantId);
}
