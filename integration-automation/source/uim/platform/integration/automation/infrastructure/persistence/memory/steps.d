/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.infrastructure.persistence.memory.step;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.workflow_step;

// import uim.platform.integration.automation.domain.ports.repositories.steps;
import uim.platform.integration.automation.domain.ports;

// import std.algorithm : filter, sort;
// import std.array : array;

class MemoryStepRepository : StepRepository {
  private WorkflowStep[StepId] store;

  WorkflowStep[] findByWorkflow(WorkflowId workflowtenantId, id tenantId) {
    auto result = store.byValue().filter!(e => e.workflowId == workflowId
        && e.tenantId == tenantId).array;
    result.sort!((a, b) => a.sequenceNumber < b.sequenceNumber);
    return result;
  }

  WorkflowStep* findById(StepId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  WorkflowStep[] findByAssignee(TenantId tenantId, UserId assignedTo) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.assignedTo == assignedTo).array;
  }

  WorkflowStep[] findByRole(TenantId tenantId, string assignedRole) {
    return store.byValue().filter!(e => e.tenantId == tenantId
        && e.assignedRole == assignedRole).array;
  }

  WorkflowStep[] findByStatus(WorkflowId workflowtenantId, id tenantId, StepStatus status) {
    return store.byValue().filter!(e => e.workflowId == workflowId
        && e.tenantId == tenantId && e.status == status).array;
  }

  WorkflowStep* findBySequence(WorkflowId workflowtenantId, id tenantId, int sequenceNumber) {
    foreach (ref s; store.byValue())
      if (s.workflowId == workflowId && s.tenantId == tenantId && s.sequenceNumber == sequenceNumber)
        return &s;
    return null;
  }

  void save(WorkflowStep step) {
    store[step.id] = step;
  }

  void update(WorkflowStep step) {
    store[step.id] = step;
  }

  void remove(StepId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }

  void removeByWorkflow(WorkflowId workflowtenantId, id tenantId) {
    StepId[] toRemove;
    foreach (ref kv; store.byKeyValue())
      if (kv.value.workflowId == workflowId && kv.value.tenantId == tenantId)
        toRemove ~= kv.key;
    foreach (id; toRemove)
      store.remove(id);
  }
}
