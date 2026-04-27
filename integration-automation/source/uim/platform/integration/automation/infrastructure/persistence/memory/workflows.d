/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.infrastructure.persistence.memory.workflow;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.workflow;

// import uim.platform.integration.automation.domain.ports.repositories.workflows;
import uim.platform.integration.automation.domain.ports;

// import std.algorithm : filter;
// import std.array : array;

class MemoryWorkflowRepository : TenantRepository!(Workflow, WorkflowId), WorkflowRepository {
  private Workflow[WorkflowId] store;

  Workflow[] findByTenant(TenantId tenantId) {
    return findAll()r!(e => e.tenantId == tenantId).array;
  }

  Workflow* findById(WorkflowId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Workflow[] findByScenario(TenantId tenantId, ScenarioId scenarioId) {
    return findAll()r!(e => e.tenantId == tenantId && e.scenarioId == scenarioId).array;
  }

  Workflow[] findByStatus(TenantId tenantId, WorkflowStatus status) {
    return findAll()r!(e => e.tenantId == tenantId && e.status == status).array;
  }

  Workflow[] findByCreator(TenantId tenantId, UserId createdBy) {
    return findAll()r!(e => e.tenantId == tenantId && e.createdBy == createdBy).array;
  }

  size_t countByTenant(TenantId tenantId) {
    return findByTenant(tenantId).length;
  }

  size_t countActiveByTenant(TenantId tenantId) {
    return findAll()r!(e => e.tenantId == tenantId
        && (e.status == WorkflowStatus.inProgress
          || e.status == WorkflowStatus.planned || e.status == WorkflowStatus.suspended))
      .array.length;
  }

  void save(Workflow workflow) {
    store[workflow.id] = workflow;
  }

  void update(Workflow workflow) {
    store[workflow.id] = workflow;
  }

  void remove(WorkflowId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
