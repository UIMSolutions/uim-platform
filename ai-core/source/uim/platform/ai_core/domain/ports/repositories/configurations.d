/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.repositories.configurations;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.configuration;
import uim.platform.ai_core;
mixin(ShowModule!());

@safe:
interface ConfigurationRepository : ITenantRepository!(Configuration, ConfigurationId) {

  bool existsById(TenantId tenantId, ResourceGroupId rgId, ConfigurationId id);
  Configuration findById(TenantId tenantId, ResourceGroupId rgId, ConfigurationId id);
  void removeById(TenantId tenantId, ResourceGroupId rgId, ConfigurationId id);

  size_t countByResourceGroup(TenantId tenantId, ResourceGroupId rgId);
  Configuration[] findByResourceGroup(TenantId tenantId, ResourceGroupId rgId);
  void removeByResourceGroup(TenantId tenantId, ResourceGroupId rgId);

  size_t countByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId);
  Configuration[] findByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId);
  void removeByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId);

  size_t countByExecutable(TenantId tenantId, ResourceGroupId rgId, ExecutableId execId);
  Configuration[] findByExecutable(TenantId tenantId, ResourceGroupId rgId, ExecutableId execId);
  void removeByExecutable(TenantId tenantId, ResourceGroupId rgId, ExecutableId execId);

}
