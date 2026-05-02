/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.ports.repositories.step;

// import uim.platform.integration.automation.domain.types;
// import uim.platform.integration.automation.domain.entities.workflow_step;
import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
/// Port for persisting and querying workflow steps.
interface StepRepository : ITenantRepository!(WorkflowStep, WorkflowStepId) {
  
  bool existsBySequence(TenantId tenantId, WorkflowId workflowId, int sequenceNumber);
  WorkflowStep findBySequence(TenantId tenantId, WorkflowId workflowId, int sequenceNumber);
  void removeBySequence(TenantId tenantId, WorkflowId workflowId, int sequenceNumber);
  
  size_t countByWorkflow(TenantId tenantId, WorkflowId workflowId);
  WorkflowStep[] findByWorkflow(TenantId tenantId, WorkflowId workflowId);
  void removeByWorkflow(TenantId tenantId, WorkflowId workflowId);

  size_t countByAssignee(TenantId tenantId, UserId assignedTo);
  WorkflowStep[] findByAssignee(TenantId tenantId, UserId assignedTo);
  void removeByAssignee(TenantId tenantId, UserId assignedTo);

  size_t countByRole(TenantId tenantId, string assignedRole);
  WorkflowStep[] findByRole(TenantId tenantId, string assignedRole);
  void removeByRole(TenantId tenantId, string assignedRole);

  size_t countByStatus(TenantId tenantId, WorkflowId workflowId, StepStatus status);
  WorkflowStep[] findByStatus(TenantId tenantId, WorkflowId workflowId, StepStatus status);
  void removeByStatus(TenantId tenantId, WorkflowId workflowId, StepStatus status);

}
