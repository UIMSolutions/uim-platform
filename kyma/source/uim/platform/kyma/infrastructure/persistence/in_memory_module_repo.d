/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.infrastructure.persistence.memory.module_repo;

import uim.platform.kyma.domain.types;
import uim.platform.kyma.domain.entities.kyma_module;
import uim.platform.kyma.domain.ports.module_repository;

// import std.algorithm : filter;
// import std.array : array;

class MemoryModuleRepository : ModuleRepository
{
  private KymaModule[ModuleId] store;

  KymaModule findById(ModuleId id)
  {
    if (auto p = id in store)
      return *p;
    return KymaModule.init;
  }

  KymaModule findByName(KymaEnvironmentId envId, string name)
  {
    foreach (ref e; store.byValue())
      if (e.environmentId == envId && e.name == name)
        return e;
    return KymaModule.init;
  }

  KymaModule[] findByEnvironment(KymaEnvironmentId envId)
  {
    return store.byValue().filter!(e => e.environmentId == envId).array;
  }

  KymaModule[] findByStatus(ModuleStatus status)
  {
    return store.byValue().filter!(e => e.status == status).array;
  }

  KymaModule[] findByType(ModuleType moduleType)
  {
    return store.byValue().filter!(e => e.moduleType == moduleType).array;
  }

  void save(KymaModule mod)
  {
    store[mod.id] = mod;
  }

  void update(KymaModule mod)
  {
    store[mod.id] = mod;
  }

  void remove(ModuleId id)
  {
    store.remove(id);
  }
}
