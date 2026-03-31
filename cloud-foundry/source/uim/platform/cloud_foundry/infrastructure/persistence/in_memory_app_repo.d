module uim.platform.cloud_foundry.infrastructure.persistence.in_memory_app_repo;

import domain.types;
import domain.entities.application;
import domain.ports.app_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryAppRepository : AppRepository
{
  private Application[AppId] store;

  Application[] findBySpace(SpaceId spaceId, TenantId tenantId)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.spaceId == spaceId)
      .array;
  }

  Application* findById(AppId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Application* findByName(SpaceId spaceId, TenantId tenantId, string name)
  {
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.spaceId == spaceId && e.name == name)
        return &e;
    return null;
  }

  Application[] findByState(SpaceId spaceId, TenantId tenantId, AppState state)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.spaceId == spaceId && e.state == state)
      .array;
  }

  Application[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  long countBySpace(SpaceId spaceId, TenantId tenantId)
  {
    return cast(long) findBySpace(spaceId, tenantId).length;
  }

  void save(Application app) { store[app.id] = app; }
  void update(Application app) { store[app.id] = app; }

  void remove(AppId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
