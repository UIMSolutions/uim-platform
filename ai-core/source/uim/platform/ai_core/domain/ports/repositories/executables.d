/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.ports.repositories.executables;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.executable;
import uim.platform.ai_core;

// mixin(ShowModule!());

@safe:
interface ExecutableRepository : ITenantRepository!(Executable, ExecutableId) {

  bool existsById(TenantId tenantId, ResourceGroupId rgId, ExecutableId id);
  Executable findById(TenantId tenantId, ResourceGroupId rgId, ExecutableId id);
  void removeById(TenantId tenantId, ResourceGroupId rgId, ExecutableId id);

  size_t countByResourceGroup(TenantId tenantId, ResourceGroupId rgId);
  Executable[] findByResourceGroup(TenantId tenantId, ResourceGroupId rgId);
  void removeByResourceGroup(TenantId tenantId, ResourceGroupId rgId);

  size_t countByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId);
  Executable[] findByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId);
  void removeByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId);

}
