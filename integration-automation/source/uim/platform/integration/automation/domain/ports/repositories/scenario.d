/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.domain.ports.repositories.scenario;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.integration_scenario;

/// Port for persisting and querying integration scenarios.
interface ScenarioRepository : ITenantRepository!(IntegrationScenario, IntegrationScenarioId) {
  size_t countByCategory(TenantId tenantId, ScenarioCategory category);
  IntegrationScenario[] findByCategory(TenantId tenantId, ScenarioCategory category);
  void removeByCategory(TenantId tenantId, ScenarioCategory category);

  size_t countByStatus(TenantId tenantId, ScenarioStatus status);
  IntegrationScenario[] findByStatus(TenantId tenantId, ScenarioStatus status);
  void removeByStatus(TenantId tenantId, ScenarioStatus status);

  size_t countBySystemType(TenantId tenantId, SystemType systemType);
  IntegrationScenario[] findBySystemType(TenantId tenantId, SystemType systemType);
  void removeBySystemType(TenantId tenantId, SystemType systemType);

}
