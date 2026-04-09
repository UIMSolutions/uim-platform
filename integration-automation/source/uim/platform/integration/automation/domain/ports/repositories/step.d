/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.ports.repositories.step;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.workflow_step;

/// Port for persisting and querying workflow steps.
interface StepRepository {
  WorkflowStep[] findByWorkflow(WorkflowId workflowtenantId, id tenantId);
  WorkflowStep* findById(StepId tenantId, id tenantId);
  WorkflowStep[] findByAssignee(TenantId tenantId, UserId assignedTo);
  WorkflowStep[] findByRole(TenantId tenantId, string assignedRole);
  WorkflowStep[] findByStatus(WorkflowId workflowtenantId, id tenantId, StepStatus status);
  WorkflowStep* findBySequence(WorkflowId workflowtenantId, id tenantId, int sequenceNumber);
  void save(WorkflowStep step);
  void update(WorkflowStep step);
  void remove(StepId tenantId, id tenantId);
  void removeByWorkflow(WorkflowId workflowtenantId, id tenantId);
}
