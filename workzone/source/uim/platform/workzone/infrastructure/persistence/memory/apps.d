/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.app_repo;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.app_registration;
import uim.platform.workzone.domain.ports.repositories.apps;

// import std.algorithm : filter;
// import std.array : array;

class MemoryAppRepository : AppRepository {
  private AppRegistration[AppId] store;

  AppRegistration[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(a => a.tenantId == tenantId).array;
  }

  AppRegistration* findById(AppId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  AppRegistration[] findByStatus(AppStatus status, TenantId tenantId) {
    return store.byValue().filter!(a => a.tenantId == tenantId && a.status == status).array;
  }

  void save(AppRegistration app) {
    store[app.id] = app;
  }

  void update(AppRegistration app) {
    store[app.id] = app;
  }

  void remove(AppId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
