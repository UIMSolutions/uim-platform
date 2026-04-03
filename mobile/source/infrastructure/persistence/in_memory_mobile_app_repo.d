/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.mobile_app_repo;

import uim.platform.mobile.domain.types;
import uim.platform.mobile.domain.entities.mobile_app;
import uim.platform.mobile.domain.ports.mobile_app_repository;

// import std.algorithm : filter;
// import std.array : array;

class MemoryMobileAppRepository : MobileAppRepository
{
  private MobileApp[MobileAppId] store;

  MobileApp findById(MobileAppId id)
  {
    if (auto p = id in store)
      return *p;
    return MobileApp.init;
  }

  MobileApp[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  MobileApp[] findByStatus(TenantId tenantId, AppStatus status)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.status == status).array;
  }

  MobileApp findByBundleId(TenantId tenantId, string bundleId)
  {
    foreach (ref e; store.byValue())
    {
      if (e.tenantId == tenantId && e.bundleId == bundleId)
        return e;
    }
    return MobileApp.init;
  }

  void save(MobileApp app)
  {
    store[app.id] = app;
  }

  void update(MobileApp app)
  {
    store[app.id] = app;
  }

  void remove(MobileAppId id)
  {
    store.remove(id);
  }
}
