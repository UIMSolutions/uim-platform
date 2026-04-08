/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.infrastructure.persistence.memory.modules;

import uim.platform.kyma.domain.types;
import uim.platform.kyma.domain.entities.kyma_module;
import uim.platform.kyma.domain.ports.repositories.modules;

// import std.algorithm : filter;
// import std.array : array;

class MemoryModuleRepository : ModuleRepository {
  private KymaModule[ModuleId] store;

  bool existsById(ModuleId moduleId) {
    return (moduleId in store) ? true : false;
  }

  KymaModule findById(ModuleId moduleId) {
    return existsById(moduleId) ? store[moduleId] : KymaModule.init;
  }

  bool existsByName(KymaEnvironmentId environmentId, string name) {
    return store.byValue().any!(e => e.environmentId == environmentId && e.name == name);
  }

  KymaModule findByName(KymaEnvironmentId environmentId, string name) {
    foreach (enviroment; store.byValue())
      if (enviroment.environmentId == environmentId && enviroment.name == name)
        return enviroment;
    return KymaModule.init;
  }

  KymaModule[] findByEnvironment(KymaEnvironmentId environmentId) {
    return store.byValue().filter!(enviroment => enviroment.environmentId == environmentId).array;
  }

  KymaModule[] findByStatus(ModuleStatus status) {
    return store.byValue().filter!(enviroment => enviroment.status == status).array;
  }

  KymaModule[] findByType(ModuleType moduleType) {
    return store.byValue().filter!(enviroment => enviroment.moduleType == moduleType).array;
  }

  void save(KymaModule mod) {
    store[mod.moduleId] = mod;
  }

  void update(KymaModule mod) {
    store[mod.moduleId] = mod;
  }

  void remove(ModuleId moduleId) {
    store.remove(moduleId);
  }
}
