/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.repositories.offline_stores;
// import uim.platform.mobile.domain.entities.offline_store;
// import uim.platform.mobile.domain.ports.repositories.offline_stores;


import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

class MemoryOfflineStoreRepository : TenantRepository!(OfflineStore, OfflineStoreId), OfflineStoreRepository {

  bool existsByName(TenantId tenantId, MobileAppId appId, string name) {
    return findByApp(tenantId, appId).any!(s => s.name == name);
  }

  OfflineStore findByName(TenantId tenantId, MobileAppId appId, string name) {
    foreach (s; findByApp(tenantId, appId)) {
      if (s.name == name)
        return s;
    }
    return OfflineStore.init;
  }

  size_t countByApp(TenantId tenantId, MobileAppId appId) {
    return findByApp(tenantId, appId).length;
  }

  OfflineStore[] filterByApp(OfflineStore[] stores, MobileAppId appId) {
    return stores.filter!(s => s.appId == appId).array;
  }
  
  OfflineStore[] findByApp(TenantId tenantId, MobileAppId appId) {
    return filterByApp(findByTenant(tenantId), appId);
  }

  void removeByApp(TenantId tenantId, MobileAppId appId) {
    findByApp(tenantId, appId).each!(s => remove(s));
  }

}
