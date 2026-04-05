/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.infrastructure.persistence.memory.hdi_containers;

import uim.platform.hana.domain.types;
import uim.platform.hana.domain.entities.hdi_container;
import uim.platform.hana.domain.ports.repositories.hdi_containers;

import std.algorithm : filter;
import std.array : array;

class MemoryHDIContainerRepository : HDIContainerRepository {
  private HDIContainer[] store;

  HDIContainer findById(HDIContainerId id) {
    foreach (ref c; store) {
      if (c.id == id)
        return c;
    }
    return HDIContainer.init;
  }

  HDIContainer[] findByTenant(TenantId tenantId) {
    return store.filter!(c => c.tenantId == tenantId).array;
  }

  HDIContainer[] findByInstance(InstanceId instanceId) {
    return store.filter!(c => c.instanceId == instanceId).array;
  }

  void save(HDIContainer c) {
    store ~= c;
  }

  void update(HDIContainer c) {
    foreach (ref existing; store) {
      if (existing.id == c.id) {
        existing = c;
        return;
      }
    }
  }

  void remove(HDIContainerId id) {
    store = store.filter!(c => c.id != id).array;
  }

  long countByTenant(TenantId tenantId) {
    return cast(long) store.filter!(c => c.tenantId == tenantId).array.length;
  }
}
