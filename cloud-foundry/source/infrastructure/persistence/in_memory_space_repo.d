module infrastructure.persistence.in_memory_space_repo;

import domain.types;
import domain.entities.space;
import domain.ports.space_repository;

import std.algorithm : filter;
import std.array : array;

class InMemorySpaceRepository : SpaceRepository
{
  private Space[SpaceId] store;

  Space[] findByOrg(OrgId orgId, TenantId tenantId)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.orgId == orgId)
      .array;
  }

  Space* findById(SpaceId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Space* findByName(OrgId orgId, TenantId tenantId, string name)
  {
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.orgId == orgId && e.name == name)
        return &e;
    return null;
  }

  Space[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  void removeByOrg(OrgId orgId, TenantId tenantId)
  {
    SpaceId[] toRemove;
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.orgId == orgId)
        toRemove ~= e.id;
    foreach (id; toRemove)
      store.remove(id);
  }

  void save(Space space) { store[space.id] = space; }
  void update(Space space) { store[space.id] = space; }

  void remove(SpaceId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
