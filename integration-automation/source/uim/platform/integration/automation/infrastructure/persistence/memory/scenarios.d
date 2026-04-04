/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.infrastructure.persistence.memory.scenarios;

import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.integration_scenario;

// import uim.platform.integration.automation.domain.ports.repositories.scenarios;
import uim.platform.integration.automation.domain.ports;

// import std.algorithm : filter;
// import std.array : array;

class MemoryScenarioRepository : ScenarioRepository {
  private IntegrationScenario[ScenarioId] store;

  IntegrationScenario[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  IntegrationScenario* findById(ScenarioId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  IntegrationScenario[] findByCategory(TenantId tenantId, ScenarioCategory category) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.category == category).array;
  }

  IntegrationScenario[] findByStatus(TenantId tenantId, ScenarioStatus status) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.status == status).array;
  }

  IntegrationScenario[] findBySystemType(TenantId tenantId, SystemType systemType) {
    return store.byValue().filter!(e => e.tenantId == tenantId
        && (e.sourceSystemType == systemType || e.targetSystemType == systemType)).array;
  }

  void save(IntegrationScenario scenario) {
    store[scenario.id] = scenario;
  }

  void update(IntegrationScenario scenario) {
    store[scenario.id] = scenario;
  }

  void remove(ScenarioId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
