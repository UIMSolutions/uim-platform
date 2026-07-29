/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_automation.infrastructure.persistence.repositories.steps;

// import uim.platform.integration_automation.domain.entities.workflow_step;
// import uim.platform.integration_automation.domain.ports.repositories.steps;

import uim.platform.integration_automation;

mixin(ShowModule!());

@safe:

class StepRepository : TenantRepository!(WorkflowStep, StepId), IStepRepository {

  size_t countByWorkflow(TenantId tenantId, WorkflowId workflowId) {
    return findByWorkflow(tenantId, workflowId).length;
  }

  WorkflowStep[] filterByWorkflow(WorkflowStep[] steps, WorkflowId workflowId, size_t offset = 0, size_t limit = 0) {
    return (limit == 0)
      ? steps.filter!(e => e.workflowId == workflowId).skip(offset).array
      : steps.filter!(e => e.workflowId == workflowId).skip(offset).take(limit).array;
  }

  WorkflowStep[] findByWorkflow(TenantId tenantId, WorkflowId workflowId) {
    auto result = findByTenant(tenantId).filter!(e => e.workflowId == workflowId
        && e.tenantId == tenantId).array;
    result.sort!((a, b) => a.sequenceNumber < b.sequenceNumber);
    return result;
  }
  void removeByWorkflow(TenantId tenantId, WorkflowId workflowId) {
    findByWorkflow(tenantId, workflowId).each!(s => remove(s));
  }

  size_t countByAssignee(TenantId tenantId, UserId assignedTo) {
    return findByAssignee(tenantId, assignedTo).length;
  }

  WorkflowStep[] filterByAssignee(WorkflowStep[] steps, UserId assignedTo) {
    return steps.filter!(e => e.assignedTo == assignedTo).array;
  }

  WorkflowStep[] findByAssignee(TenantId tenantId, UserId assignedTo) {
    return findByTenant(tenantId).filter!(e => e.tenantId == tenantId && e.assignedTo == assignedTo).array;
  }

  void removeByAssignee(TenantId tenantId, UserId assignedTo) {
    findByAssignee(tenantId, assignedTo).each!(s => remove(s));
  }

  size_t countByRole(TenantId tenantId, string assignedRole) {
    return findByRole(tenantId, assignedRole).length;
  }

  WorkflowStep[] filterByRole(WorkflowStep[] steps, string assignedRole) {
    return steps.filter!(e => e.assignedRole == assignedRole).array;
  }

  WorkflowStep[] findByRole(TenantId tenantId, string assignedRole) {
    return findByTenant(tenantId).filter!(e => e.tenantId == tenantId
        && e.assignedRole == assignedRole).array;
  }

  void removeByRole(TenantId tenantId, string assignedRole) {
    findByRole(tenantId, assignedRole).each!(s => remove(s));
  }

  size_t countByStatus(TenantId tenantId, WorkflowId workflowId, StepStatus status) {
    return findByStatus(tenantId, workflowId, status).length;
  }
  
  WorkflowStep[] filterByStatus(WorkflowStep[] steps, WorkflowId workflowId, StepStatus status) {
    return steps.filter!(e => e.workflowId == workflowId && e.status == status).array;
  }

  WorkflowStep[] findByStatus(TenantId tenantId, WorkflowId workflowId, StepStatus status) {
    return findByTenant(tenantId).filter!(e => e.workflowId == workflowId
        && e.tenantId == tenantId && e.status == status).array;
  }

  void removeByStatus(TenantId tenantId, WorkflowId workflowId, StepStatus status) {
    findByStatus(tenantId, workflowId, status).each!(s => remove(s));
  }

  WorkflowStep findBySequence(TenantId tenantId, WorkflowId workflowId, int sequenceNumber) {
    foreach (s; findByTenant(tenantId))
      if (s.workflowId == workflowId && s.tenantId == tenantId && s.sequenceNumber == sequenceNumber)
        return &s;
    return null;
  }

  // void removeByWorkflow(TenantId tenantId, WorkflowId workflowId) {
    // StepId[] toRemove;
    // foreach (kv; store.byKeyValue())
      // if (kv.value.workflowId == workflowId && kv.value.tenantId == tenantId)
        // toRemove ~= kv.key;
    // foreach (id; toRemove)
      // removeById(tenantId, id);
  // }
}
