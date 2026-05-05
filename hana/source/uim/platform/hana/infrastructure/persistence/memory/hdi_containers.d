/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.infrastructure.persistence.memory.hdi_containers;

// import uim.platform.hana.domain.types;
// import uim.platform.hana.domain.entities.hdi_container;
// import uim.platform.hana.domain.ports.repositories.hdi_containers;
// 
// import std.algorithm : filter;
// import std.array : array;
import uim.platform.hana;

mixin(ShowModule!());

@safe:
class MemoryHDIContainerRepository : TenantRepository!(HDIContainer, HDIContainerId), HDIContainerRepository {


  size_t countByInstance(DatabaseInstanceId instanceId) {
    return findByInstance(instanceId).length;
  }

  HDIContainer[] filterByInstance(HDIContainer[] containers, DatabaseInstanceId instanceId) {
    return containers.filter!(c => c.instanceId == instanceId).array;
  }

  HDIContainer[] findByInstance(DatabaseInstanceId instanceId) {
    return filterByInstance(findAll(), instanceId);
  }

  void removeByInstance(DatabaseInstanceId instanceId) {
    findByInstance(instanceId).each!(c => remove(c.id));
  }
}
