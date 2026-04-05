/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.hana.infrastructure.persistence.memory.database_users;

import uim.platform.hana.domain.types;
import uim.platform.hana.domain.entities.database_user;
import uim.platform.hana.domain.ports.repositories.database_users;

import std.algorithm : filter;
import std.array : array;

class MemoryDatabaseUserRepository : DatabaseUserRepository {
  private DatabaseUser[] store;

  DatabaseUser findById(DatabaseUserId id) {
    foreach (ref u; store) {
      if (u.id == id)
        return u;
    }
    return DatabaseUser.init;
  }

  DatabaseUser[] findByTenant(TenantId tenantId) {
    return store.filter!(u => u.tenantId == tenantId).array;
  }

  DatabaseUser[] findByInstance(InstanceId instanceId) {
    return store.filter!(u => u.instanceId == instanceId).array;
  }

  void save(DatabaseUser u) {
    store ~= u;
  }

  void update(DatabaseUser u) {
    foreach (ref existing; store) {
      if (existing.id == u.id) {
        existing = u;
        return;
      }
    }
  }

  void remove(DatabaseUserId id) {
    store = store.filter!(u => u.id != id).array;
  }

  long countByTenant(TenantId tenantId) {
    return cast(long) store.filter!(u => u.tenantId == tenantId).array.length;
  }
}
