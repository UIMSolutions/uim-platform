/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.infrastructure.persistence.memory.route;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.route;
import uim.platform.foundry.domain.ports.repositories.route;

// import std.algorithm : canFind, filter;
// import std.array : array;

class MemoryRouteRepository : RouteRepository {
  private Route[RouteId] store;

  Route[] findBySpace(SpaceId spacetenantId, id tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.spaceId == spaceId).array;
  }

  Route* findById(RouteId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Route* findByHostAndDomain(TenantId tenantId, string host, DomainId domainId) {
    foreach (e; store.byValue())
      if (e.tenantId == tenantId && e.host == host && e.domainId == domainId)
        return &e;
    return null;
  }

  Route[] findByDomain(DomainId domaintenantId, id tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.domainId == domainId).array;
  }

  Route[] findByApp(AppId apptenantId, id tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId
        && e.mappedAppIds.canFind(appId)).array;
  }

  Route[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  void save(Route route) {
    store[route.id] = route;
  }

  void update(Route route) {
    store[route.id] = route;
  }

  void remove(RouteId tenantId, id tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
