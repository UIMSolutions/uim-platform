/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.infrastructure.persistence.memory.scenarios;

// import uim.platform.integration.automation.domain.types;
// import uim.platform.integration.automation.domain.entities.integration_scenario;

// // import uim.platform.integration.automation.domain.ports.repositories.scenarios;
// import uim.platform.integration.automation.domain.ports;

import uim.platform.integration.automation;

mixin(ShowModule!());

@safe:
class MemoryScenarioRepository : TenantRepository!(IntegrationScenario, ScenarioId), ScenarioRepository {

  size_t countByCategory(TenantId tenantId, ScenarioCategory category) {
    return findByCategory(tenantId, category).length;
  }

  IntegrationScenario[] filterByCategory(IntegrationScenario[] scenarios, ScenarioCategory category, uint offset = 0, uint limit = 0) {
    return (limit == 0)
      ? scenarios.filter!(e => e.category == category).skip(offset).array
      : scenarios.filter!(e => e.category == category).skip(offset).take(limit).array;
  }

  IntegrationScenario[] findByCategory(TenantId tenantId, ScenarioCategory category) {
    return findByTenant(tenantId).filter!(e => e.category == category).array;
  }

  void removeByCategory(TenantId tenantId, ScenarioCategory category) {
    filterByCategory(findByTenant(tenantId), category).each!(e => remove(e));
  }

  size_t countByStatus(TenantId tenantId, ScenarioStatus status) {
    return findByStatus(tenantId, status).length;
  }

  IntegrationScenario[] filterByStatus(IntegrationScenario[] scenarios, ScenarioStatus status, uint offset = 0, uint limit = 0) {
    return (limit == 0)
      ? scenarios.filter!(e => e.status == status).skip(offset).array
      : scenarios.filter!(e => e.status == status).skip(offset).take(limit).array;
  }

  IntegrationScenario[] findByStatus(TenantId tenantId, ScenarioStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, ScenarioStatus status) {
    filterByStatus(findByTenant(tenantId), status).each!(e => remove(e));
  }

  size_t countBySystemType(TenantId tenantId, SystemType systemType) {
    return findBySystemType(tenantId, systemType).length;
  }

  IntegrationScenario[] filterBySystemType(IntegrationScenario[] scenarios, SystemType systemType, uint offset = 0, uint limit = 0) {
    return (limit == 0)
      ? scenarios.filter!(e => e.sourceSystemType == systemType || e.targetSystemType == systemType).skip(offset)
      .array : scenarios.filter!(e => e.sourceSystemType == systemType || e.targetSystemType == systemType).skip(
        offset).take(limit).array;
  }

  IntegrationScenario[] findBySystemType(TenantId tenantId, SystemType systemType) {
    return filterBySystemType(findByTenant(tenantId), systemType);
  }

  void removeBySystemType(TenantId tenantId, SystemType systemType) {
    filterBySystemType(findByTenant(tenantId), systemType).each!(e => remove(e));
  }

}
