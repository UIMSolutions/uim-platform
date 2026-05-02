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
class MemoryConfigurationRepository : IConfigurationRepository {
  private Configuration[] store;

  void save(Configuration c) {
    foreach (existing; findAll) {
      if (existing.id == c.id && existing.connectionId == c.connectionId) {
        existing = c;
        return;
      }
    }
    store ~= c;
  }

  Configuration findById(ConfigurationId id, ConnectionId connectionId) {
    foreach (c; findAll) {
      if (c.id == id && c.connectionId == connectionId) return c;
    }
    return Configuration.init;
  }

  Configuration[] findByConnection(ConnectionId connectionId) {
    Configuration[] result;
    foreach (c; findAll) {
      if (c.connectionId == connectionId) result ~= c;
    }
    return result;
  }

  Configuration[] findByScenario(ScenarioId scenarioId, ConnectionId connectionId) {
    Configuration[] result;
    foreach (c; findAll) {
      if (c.scenarioId == scenarioId && c.connectionId == connectionId) result ~= c;
    }
    return result;
  }

  Configuration[] findAll() {
    return store.dup;
  }

  void remove(ConfigurationId id, ConnectionId connectionId) {
    Configuration[] filtered;
    foreach (c; findAll) {
      if (!(c.id == id && c.connectionId == connectionId)) filtered ~= c;
    }
    store = filtered;
  }
}
