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

  size_t countByScenario(TenantId tenantId, ScenarioId scenarioId) {
    return findByScenario(tenantId, scenarioId).length;
  }
  Workflow[] filterByScenario(Workflow[] workflows, ScenarioId scenarioId) {
    return workflows.filter!(e => e.scenarioId == scenarioId).array;
  }
  Workflow[] findByScenario(TenantId tenantId, ScenarioId scenarioId) {
    return filterByScenario(findByTenant(tenantId), scenarioId);
  }
  void removeByScenario(TenantId tenantId, ScenarioId scenarioId) {
    findByScenario(tenantId, scenarioId).each!(e => remove(e.id));
  }

  size_t countByStatus(TenantId tenantId, WorkflowStatus status) {
    return findByStatus(tenantId, status).length;
  }
  Workflow[] filterByStatus(Workflow[] workflows, TenantId tenantId, WorkflowStatus status) {
    return workflows.filter!(e => e.tenantId == tenantId && e.status == status).array;
  }
  Workflow[] findByStatus(TenantId tenantId, WorkflowStatus status) {
    return filterByStatus(findByTenant(tenantId), tenantId, status);
  }
  void removeByStatus(TenantId tenantId, WorkflowStatus status) {
    findByStatus(tenantId, status).each!(e => remove(e.id));
  }

  size_t countByCreator(TenantId tenantId, UserId createdBy) {
    return findByCreator(tenantId, createdBy).length;
  }
  Workflow[] filterByCreator(Workflow[] workflows, UserId createdBy) {
    return workflows.filter!(e => e.createdBy == createdBy).array;
  }
  Workflow[] findByCreator(TenantId tenantId, UserId createdBy) {
    return filterByCreator(findByTenant(tenantId), createdBy);
  }
  void removeByCreator(TenantId tenantId, UserId createdBy) {
    findByCreator(tenantId, createdBy).each!(e => remove(e.id));
  }

  size_t countActiveByTenant(TenantId tenantId) {
    return findAll().filter!(e => e.tenantId == tenantId
        && (e.status == WorkflowStatus.inProgress
          || e.status == WorkflowStatus.planned || e.status == WorkflowStatus.suspended))
      .array.length;
  }

}
