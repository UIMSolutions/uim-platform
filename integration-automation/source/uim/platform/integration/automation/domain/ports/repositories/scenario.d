/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.ports.repositories.scenario;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.integration_scenario;

/// Port for persisting and querying integration scenarios.
interface ScenarioRepository
{
  IntegrationScenario[] findByTenant(TenantId tenantId);
  IntegrationScenario* findById(ScenarioId id, TenantId tenantId);
  IntegrationScenario[] findByCategory(TenantId tenantId, ScenarioCategory category);
  IntegrationScenario[] findByStatus(TenantId tenantId, ScenarioStatus status);
  IntegrationScenario[] findBySystemType(TenantId tenantId, SystemType systemType);
  void save(IntegrationScenario scenario);
  void update(IntegrationScenario scenario);
  void remove(ScenarioId id, TenantId tenantId);
}
