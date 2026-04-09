/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.ports.repositories.workflow;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.workflow;

/// Port for persisting and querying workflow instances.
interface WorkflowRepository {
  Workflow[] findByTenant(TenantId tenantId);
  Workflow* findById(WorkflowId tenantId, id tenantId);
  Workflow[] findByScenario(TenantId tenantId, ScenarioId scenarioId);
  Workflow[] findByStatus(TenantId tenantId, WorkflowStatus status);
  Workflow[] findByCreator(TenantId tenantId, UserId createdBy);
  long countByTenant(TenantId tenantId);
  long countActiveByTenant(TenantId tenantId);
  void save(Workflow workflow);
  void update(Workflow workflow);
  void remove(WorkflowId tenantId, id tenantId);
}
