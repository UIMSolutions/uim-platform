/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.offline_store;

import uim.platform.mobile.domain.entities.offline_store;
import uim.platform.mobile.domain.ports.repositories.offline_stores;
import uim.platform.mobile.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryOfflineStoreRepository : OfflineStoreRepository {
  private OfflineStore[OfflineStoreId] store;

  OfflineStore findById(OfflineStoreId id) {
    if (auto p = id in store)
      return *p;
    return OfflineStore.init;
  }

  OfflineStore findByName(MobileAppId appId, string name) {
    foreach (s; store) {
      if (s.appId == appId && s.name == name)
        return s;
    }
    return OfflineStore.init;
  }

  OfflineStore[] findByApp(MobileAppId appId) {
    return store.values.filter!(s => s.appId == appId).array;
  }

  OfflineStore[] findByTenant(TenantId tenantId) {
    return store.values.filter!(s => s.tenantId == tenantId).array;
  }

  void save(OfflineStore s) {
    store[s.id] = s;
  }

  void update(OfflineStore s) {
    store[s.id] = s;
  }

  void remove(OfflineStoreId id) {
    store.remove(id);
  }

  size_t countByApp(MobileAppId appId) {
    return cast(long) store.values.filter!(s => s.appId == appId).array.length;
  }
}
