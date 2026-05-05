/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.infrastructure.persistence.memory.step;

// import uim.platform.integration.automation.domain.types;
// import uim.platform.integration.automation.domain.entities.workflow_step;

// // import uim.platform.integration.automation.domain.ports.repositories.steps;
// import uim.platform.integration.automation.domain.ports;

import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:

class MemoryStepRepository : TenantRepository!(WorkflowStep, StepId), StepRepository {

  size_t countByWorkflow(TenantId tenantId, WorkflowId workflowId) {
    return findByWorkflow(tenantId, workflowId).length;
  }
  WorkflowStep[] findByWorkflow(TenantId tenantId, WorkflowId workflowId) {
    auto result = findAll().filter!(e => e.workflowId == workflowId
        && e.tenantId == tenantId).array;
    result.sort!((a, b) => a.sequenceNumber < b.sequenceNumber);
    return result;
  }
  void removeByWorkflow(TenantId tenantId, WorkflowId workflowId) {
    findByWorkflow(tenantId, workflowId).each!(s => store.remove(s));
  }

  WorkflowStep findById(TenantId tenantId, StepId id) {
    if (id in store)
      if (store[id].tenantId == tenantId)
        return store[id];
    return WorkflowStep.init;
  }

  WorkflowStep[] findByAssignee(TenantId tenantId, UserId assignedTo) {
    return findAll().filter!(e => e.tenantId == tenantId && e.assignedTo == assignedTo).array;
  }

  WorkflowStep[] findByRole(TenantId tenantId, string assignedRole) {
    return findAll().filter!(e => e.tenantId == tenantId
        && e.assignedRole == assignedRole).array;
  }

  WorkflowStep[] findByStatus(TenantId tenantId, WorkflowId workflowId, StepStatus status) {
    return findAll().filter!(e => e.workflowId == workflowId
        && e.tenantId == tenantId && e.status == status).array;
  }

  WorkflowStep findBySequence(TenantId tenantId, WorkflowId workflowId, int sequenceNumber) {
    foreach (s; findAll())
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

  void remove(StepId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        removeById(id);
  }

  void removeByWorkflow(TenantId tenantId, WorkflowId workflowId) {
    StepId[] toRemove;
    foreach (kv; store.byKeyValue())
      if (kv.value.workflowId == workflowId && kv.value.tenantId == tenantId)
        toRemove ~= kv.key;
    foreach (id; toRemove)
      removeById(id);
  }
}
