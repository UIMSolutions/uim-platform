/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.memory.scenarios;

// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.scenario;
// import uim.platform.ai_core.domain.ports.repositories.scenarios;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
class MemoryScenarioRepository : TenantRepository!(Scenario, ScenarioId), ScenarioRepository {

  // TODO: Implement methods for finding and removing scenarios by tenant, if needed. 
  size_t countByResourceGroup(ResourceGroupId rgId) {
    return findByResourceGroup(rgId).length;
  }

  Scenario[] findByResourceGroup(ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      return *rg;
    return null;
  }

  void removeByResourceGroup(ResourceGroupId rgId) {
    if (auto rg = rgId in store)
      (rg).each!(e => remove(e));
  }

}
