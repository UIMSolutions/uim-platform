/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.environment_instance;

// import uim.platform.management.domain.types;
// import uim.platform.management.domain.entities.environment_instance;
// import uim.platform.management.domain.ports.repositories.environment_instances;

// // import std.algorithm : filter;
// // import std.array : array;

import uim.platform.management;

mixin(ShowModule!());
@safe:

class MemoryEnvironmentInstanceRepository : EnvironmentInstanceRepository {
  private EnvironmentInstance[EnvironmentInstanceId] store;

  EnvironmentInstance findById(EnvironmentInstanceId id) {
    if (auto p = id in store)
      return *p;
    return EnvironmentInstance.init;
  }

  EnvironmentInstance[] findBySubaccount(SubaccountId subaccountId) {
    return store.byValue().filter!(e => e.subaccountId == subaccountId).array;
  }

  EnvironmentInstance[] findByType(SubaccountId subaccountId, EnvironmentType envType) {
    return store.byValue().filter!(e => e.subaccountId == subaccountId
        && e.environmentType == envType).array;
  }

  EnvironmentInstance[] findByStatus(SubaccountId subaccountId, EnvironmentStatus status) {
    return store.byValue().filter!(e => e.subaccountId == subaccountId && e.status == status).array;
  }

  void save(EnvironmentInstance inst) {
    store[inst.id] = inst;
  }

  void update(EnvironmentInstance inst) {
    store[inst.id] = inst;
  }

  void remove(EnvironmentInstanceId id) {
    store.remove(id);
  }
}
