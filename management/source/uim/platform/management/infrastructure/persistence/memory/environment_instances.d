/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.persistence.memory.environment_instances;

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

  bool existsById(EnvironmentInstanceId id) {
    return (id in store) ? true : false;
  }

  EnvironmentInstance findById(EnvironmentInstanceId id) {
    return existsById(id) ? store[id] : EnvironmentInstance.init;
  }

  EnvironmentInstance[] findBySubaccount(SubaccountId subaccountId) {
    return findAll()r!(e => e.subaccountId == subaccountId).array;
  }

  EnvironmentInstance[] findByType(SubaccountId subaccountId, EnvironmentType envType) {
    return findBySubaccount(subaccountId).filter!(e => e.environmentType == envType).array;
  }

  EnvironmentInstance[] findByStatus(SubaccountId subaccountId, EnvironmentStatus status) {
    return findBySubaccount(subaccountId).filter!(e => e.status == status).array;
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
