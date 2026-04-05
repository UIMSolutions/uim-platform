/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.infrastructure.persistence.memory.instances;

import uim.platform.hana.domain.types;
import uim.platform.hana.domain.entities.instance;
import uim.platform.hana.domain.ports.repositories.instances;

import std.algorithm : filter;
import std.array : array;

class MemoryInstanceRepository : InstanceRepository {
  private DatabaseInstance[] store;

  DatabaseInstance findById(InstanceId id) {
    foreach (ref i; store) {
      if (i.id == id)
        return i;
    }
    return DatabaseInstance.init;
  }

  DatabaseInstance[] findByTenant(TenantId tenantId) {
    return store.filter!(i => i.tenantId == tenantId).array;
  }

  void save(DatabaseInstance i) {
    store ~= i;
  }

  void update(DatabaseInstance i) {
    foreach (ref existing; store) {
      if (existing.id == i.id) {
        existing = i;
        return;
      }
    }
  }

  void remove(InstanceId id) {
    store = store.filter!(i => i.id != id).array;
  }

  long countByTenant(TenantId tenantId) {
    return cast(long) store.filter!(i => i.tenantId == tenantId).array.length;
  }
}
