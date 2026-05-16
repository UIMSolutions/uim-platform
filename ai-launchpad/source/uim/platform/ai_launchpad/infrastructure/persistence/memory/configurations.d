/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.configurations;
// import uim.platform.ai_launchpad.domain.ports.repositories.configurations;
// import uim.platform.ai_launchpad.domain.entities.configuration : Configuration;
// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:
class MemoryConfigurationRepository : TenantRepository!(Configuration, ConfigurationId), IConfigurationRepository {
  
  bool existsById(TenantId tenantId, ConnectionId connectionId, ConfigurationId id) {
    return findByConnection(tenantId, connectionId).any!(c => c.id == id); 
  }

  Configuration findById(TenantId tenantId, ConnectionId connectionId, ConfigurationId id) {
    foreach (c; findByConnection(tenantId, connectionId)) {
      if (c.id == id) return c;
    }
    return Configuration.init;
  }
  void removeById(TenantId tenantId, ConnectionId connectionId, ConfigurationId id) {
    remove(tenantId, connectionId, id);
  }

  size_t countByConnection(TenantId tenantId, ConnectionId connectionId) {
    return findByConnection(tenantId, connectionId).length;
  }
  Configuration[] findByConnection(TenantId tenantId, ConnectionId connectionId) {
    return filterByConnection(findByTenant(tenantId), connectionId);
  }
  void removeByConnection(TenantId tenantId, ConnectionId connectionId) {
    findByConnection(tenantId, connectionId).each!(c => remove(c));
  }

  size_t countByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    return findByScenario(tenantId, connectionId, scenarioId).length;
  }
  Configuration[] filterByScenario(Configuration[] configs, ScenarioId scenarioId) {
    return configs.filter!(c => c.scenarioId == scenarioId);
  }
  Configuration[] findByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    return filterByScenario(findByConnection(tenantId, connectionId), scenarioId);
  }
  void removeByScenario(TenantId tenantId, ConnectionId connectionId, ScenarioId scenarioId) {
    findByScenario(tenantId, connectionId, scenarioId).each!(c => remove(c));
  }

}
