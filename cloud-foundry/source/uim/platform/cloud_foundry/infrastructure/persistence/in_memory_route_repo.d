module uim.platform.cloud_foundry.infrastructure.persistence.in_memory_route_repo;

import domain.types;
import domain.entities.route;
import domain.ports.route_repository;

import std.algorithm : canFind, filter;
import std.array : array;

class InMemoryRouteRepository : RouteRepository
{
  private Route[RouteId] store;

  Route[] findBySpace(SpaceId spaceId, TenantId tenantId)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.spaceId == spaceId)
      .array;
  }

  Route* findById(RouteId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Route* findByHostAndDomain(TenantId tenantId, string host, DomainId domainId)
  {
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.host == host && e.domainId == domainId)
        return &e;
    return null;
  }

  Route[] findByDomain(DomainId domainId, TenantId tenantId)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.domainId == domainId)
      .array;
  }

  Route[] findByApp(AppId appId, TenantId tenantId)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.mappedAppIds.canFind(appId))
      .array;
  }

  Route[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  void save(Route route) { store[route.id] = route; }
  void update(Route route) { store[route.id] = route; }

  void remove(RouteId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
