/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.ports.repositories.workflow;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.workflow;

/// Port for persisting and querying workflow instances.
interface WorkflowRepository : ITenantRepository!(Workflow, WorkflowId) {

  size_t countActiveByTenant(TenantId tenantId);

  size_t countByScenario(TenantId tenantId, ScenarioId scenarioId);
  Workflow[] findByScenario(TenantId tenantId, ScenarioId scenarioId);
  void removeByScenario(TenantId tenantId, ScenarioId scenarioId);

  size_t countByStatus(TenantId tenantId, WorkflowStatus status);
  Workflow[] findByStatus(TenantId tenantId, WorkflowStatus status);
  void removeByStatus(TenantId tenantId, WorkflowStatus status);

  size_t countByCreator(TenantId tenantId, UserId createdBy);
  Workflow[] findByCreator(TenantId tenantId, UserId createdBy);
  void removeByCreator(TenantId tenantId, UserId createdBy);
  
}
