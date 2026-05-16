/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.memory.configurations;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.configuration;
// import uim.platform.ai_core.domain.ports.repositories.configurations;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:
class MemoryConfigurationRepository : TenantRepository!(Configuration, ConfigurationId), ConfigurationRepository {

  size_t countByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    return findByResourceGroup(tenantId, rgId).length;
  }
  Configuration[] findByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    return filterByResourceGroup(findByTenant(tenantId), rgId);
  }
  void removeByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    findByResourceGroup(tenantId, rgId).each!(c => remove(c));
  }

  size_t countByScenario(TenantId tenantId, ScenarioId scenarioId, ResourceGroupId rgId) {
    return findByScenario(tenantId, scenarioId, rgId).length;
  }
  Configuration[] filterByScenario(Configuration[] configs, ScenarioId scenarioId) {
    return configs.filter!(c => c.scenarioId == scenarioId).array;
  }
  Configuration[] findByScenario(TenantId tenantId, ScenarioId scenarioId, ResourceGroupId rgId){
    return filterByScenario(findByResourceGroup(tenantId, rgId), scenarioId);
  }
  void removeByScenario(TenantId tenantId, ScenarioId scenarioId, ResourceGroupId rgId) {
    findByScenario(tenantId, scenarioId, rgId).each!(c => remove(c));
  }

  size_t countByExecutable(TenantId tenantId, ExecutableId execId, ResourceGroupId rgId) {
    return findByExecutable(tenantId, execId, rgId).length;
  }
  Configuration[] filterByExecutable(Configuration[] configs, ExecutableId execId) {
    return configs.filter!(c => c.executableId == execId).array;
  }
  Configuration[] findByExecutable(TenantId tenantId, ExecutableId execId, ResourceGroupId rgId){
    return filterByExecutable(findByResourceGroup(tenantId, rgId), execId);
  }
  void removeByExecutable(TenantId tenantId, ExecutableId execId, ResourceGroupId rgId) {
    findByExecutable(tenantId, execId, rgId).each!(c => remove(c));
  } 


}
