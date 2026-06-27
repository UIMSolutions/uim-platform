/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.memory.scenarios;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.scenario;
// import uim.platform.ai_core.domain.ports.repositories.scenarios;


 
import uim.platform.ai_core;

// mixin(ShowModule!()); 

@safe:
class MemoryScenarioRepository : TentRepository!(Scenario, ScenarioId), ScenarioRepository {

  bool existsById(TenantId tenantId, ResourceGroupId rgId, ScenarioId id) {
    return findByResourceGroup(tenantId, rgId).any!(s => s.id == id);
  }
  Scenario findById(TenantId tenantId, ResourceGroupId rgId, ScenarioId id) {
    auto scenarios = findByResourceGroup(tenantId, rgId);
    foreach (s; scenarios) {
      if (s.id == id) {
        return s;
      }
    }
    return Scenario.init;
  }
  void removeById(TenantId tenantId, ResourceGroupId rgId, ScenarioId id) {
    auto scenario = findById(tenantId, rgId, id);
    remove(scenario);
  }

  // TODO: Implement methods for finding and removing scenarios by tenant, if needed. 
  size_t countByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    return findByResourceGroup(tenantId, rgId).length;
  }

  Scenario[] findByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    return filterByResourceGroup(findByTenant(tenantId), rgId);
  }

  void removeByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    findByResourceGroup(tenantId, rgId).each!(s => remove(s));
  }

}
