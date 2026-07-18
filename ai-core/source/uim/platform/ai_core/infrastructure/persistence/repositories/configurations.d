/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.repositories.configurations;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.configuration;
// import uim.platform.ai_core.domain.ports.repositories.configurations;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:
class MemoryConfigurationRepository : TenantRepository!(Configuration, ConfigurationId), ConfigurationRepository {

  bool existsById(TenantId tenantId, ResourceGroupId rgId, ConfigurationId id) {
    return findByResourceGroup(tenantId, rgId).any!(c => c.id == id);
  }

  Configuration findById(TenantId tenantId, ResourceGroupId rgId, ConfigurationId id) {
    foreach (c; findByResourceGroup(tenantId, rgId)) {
      if (c.id == id) {
        return c;
      }
    }

    return Configuration.init;
  }

  void removeById(TenantId tenantId, ResourceGroupId rgId, ConfigurationId id) {
    auto config = findById(tenantId, rgId, id);
    if (!config.isNull) {
      remove(config);
    }
  }

  size_t countByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    return findByResourceGroup(tenantId, rgId).length;
  }

  Configuration[] findByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    return filterByResourceGroup(findByTenant(tenantId), rgId);
  }

  void removeByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    findByResourceGroup(tenantId, rgId).each!(c => remove(c));
  }

  size_t countByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId) {
    return findByScenario(tenantId, rgId, scenarioId).length;
  }

  Configuration[] filterByScenario(Configuration[] configs, ScenarioId scenarioId) {
    return configs.filter!(c => c.scenarioId == scenarioId).array;
  }

  Configuration[] findByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId) {
    return filterByScenario(findByResourceGroup(tenantId, rgId), scenarioId);
  }

  void removeByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId) {
    findByScenario(tenantId, rgId, scenarioId).each!(c => remove(c));
  }

  size_t countByExecutable(TenantId tenantId, ResourceGroupId rgId, ExecutableId execId) {
    return findByExecutable(tenantId, rgId, execId).length;
  }

  Configuration[] filterByExecutable(Configuration[] configs, ExecutableId execId) {
    return configs.filter!(c => c.executableId == execId).array;
  }

  Configuration[] findByExecutable(TenantId tenantId, ResourceGroupId rgId, ExecutableId execId) {
    return filterByExecutable(findByResourceGroup(tenantId, rgId), execId);
  }

  void removeByExecutable(TenantId tenantId, ResourceGroupId rgId, ExecutableId execId) {
    findByExecutable(tenantId, rgId, execId).each!(c => remove(c));
  }

}
