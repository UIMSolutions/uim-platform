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
class MemoryHDIContainerRepository : HDIContainerRepository {
  private HDIContainer[] store;

  HDIContainer findById(HDIContainerId id) {
    foreach (c; findAll) {
      if (c.id == id)
        return c;
    }
    return HDIContainer.init;
  }

  HDIContainer[] findByTenant(TenantId tenantId) {
    return findAll().filter!(c => c.tenantId == tenantId).array;
  }

  HDIContainer[] findByInstance(InstanceId instanceId) {
    return findAll().filter!(c => c.instanceId == instanceId).array;
  }

  void save(HDIContainer c) {
    store ~= c;
  }

  void update(HDIContainer c) {
    foreach (existing; findAll) {
      if (existing.id == c.id) {
        existing = c;
        return;
      }
    }
  }

  void remove(HDIContainerId id) {
    store = findAll().filter!(c => c.id != id).array;
  }

  size_t countByTenant(TenantId tenantId) {
    return findAll().filter!(c => c.tenantId == tenantId).array.length;
  }
}
