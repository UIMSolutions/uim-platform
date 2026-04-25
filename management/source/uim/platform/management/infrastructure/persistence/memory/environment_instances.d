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

class MemoryEnvironmentInstanceRepository : IdRepository!(EnvironmentInstance, EnvironmentInstanceId), EnvironmentInstanceRepository {
  // TODO: mixin IdRepositoryTemplate!(MemoryEnvironmentInstanceRepository, EnvironmentInstance, EnvironmentInstanceId);

  size_t countBySubaccount(SubaccountId subaccountId) {
    return findBySubaccount(subaccountId).length;
  }

  EnvironmentInstance[] filterBySubaccount(EnvironmentInstance[] items, SubaccountId subaccountId) {
    return items.filter!(e => e.subaccountId == subaccountId).array;
  }

  EnvironmentInstance[] findBySubaccount(SubaccountId subaccountId) {
    return filterBySubaccount(findAll(), subaccountId);
  }

  void removeBySubaccount(SubaccountId subaccountId) {
    findBySubaccount(subaccountId).each!(e => remove(e));
  }

  size_t countByType(SubaccountId subaccountId, EnvironmentType envType) {
    return findByType(subaccountId, envType).length;
  }

  EnvironmentInstance[] filterByType(EnvironmentInstance[] items, SubaccountId subaccountId, EnvironmentType envType) {
    return items.filter!(e => e.subaccountId == subaccountId && e.environmentType == envType).array;
  }
  
  EnvironmentInstance[] findByType(SubaccountId subaccountId, EnvironmentType envType) {
    return filterByType(findAll(), subaccountId, envType);
  }

  void removeByType(SubaccountId subaccountId, EnvironmentType envType) {
    findByType(subaccountId, envType).each!(e => remove(e));
  }

  size_t countByStatus(SubaccountId subaccountId, EnvironmentStatus status) {
    return findByStatus(subaccountId, status).length;
  }

  EnvironmentInstance[] filterByStatus(EnvironmentInstance[] items, SubaccountId subaccountId, EnvironmentStatus status) {
    return items.filter!(e => e.subaccountId == subaccountId && e.status == status).array;
  }

  EnvironmentInstance[] findByStatus(SubaccountId subaccountId, EnvironmentStatus status) {
    return filterByStatus(findAll(), subaccountId, status);
  }

  void removeByStatus(SubaccountId subaccountId, EnvironmentStatus status) {
    findByStatus(subaccountId, status).each!(e => remove(e));
  }

}
