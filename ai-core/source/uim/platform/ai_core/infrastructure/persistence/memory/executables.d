/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.memory.executables;
// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.executable;
// import uim.platform.ai_core.domain.ports.repositories.executables;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:
class MemoryExecutableRepository : TenantRepository!(Executable, ExecutableId), ExecutableRepository {

  bool existsById(TenantId tenantId, ResourceGroupId rgId, ExecutableId id) {
    return findByResourceGroup(tenantId, rgId).any!(e => e.id == id);
  }

  Executable findById(TenantId tenantId, ResourceGroupId rgId, ExecutableId id) {
    auto executables = findByResourceGroup(tenantId, rgId);
    foreach (e; executables) {
      if (e.id == id) {
        return e;
      }
    }
    return Executable.init;
  }

  void removeById(TenantId tenantId, ResourceGroupId rgId, ExecutableId id) {
    auto executable = findById(tenantId, rgId, id);
    remove(executable);
  }

  size_t countByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    return findByResourceGroup(tenantId, rgId).length;
  }

  Executable[] findByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    return filterByResourceGroup(findByTenant(tenantId), rgId);
  }

  void removeByResourceGroup(TenantId tenantId, ResourceGroupId rgId) {
    findByResourceGroup(tenantId, rgId).each!(e => remove(e));
  }

  size_t countByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId) {
    return findByScenario(tenantId, rgId, scenarioId).length;
  }

  Executable[] filterByScenario(Executable[] executables, ScenarioId scenarioId) {
    return executables.filter!(e => e.scenarioId == scenarioId).array;
  }

  Executable[] findByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId) {
    return filterByScenario(findByResourceGroup(tenantId, rgId), scenarioId);
  }

  void removeByScenario(TenantId tenantId, ResourceGroupId rgId, ScenarioId scenarioId) {
    findByScenario(tenantId, rgId, scenarioId).each!(e => remove(e));
  }

}
