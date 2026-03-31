module infrastructure.persistence.in_memory_buildpack_repo;

import domain.types;
import domain.entities.buildpack;
import domain.ports.buildpack_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryBuildpackRepository : BuildpackRepository
{
  private Buildpack[BuildpackId] store;

  Buildpack[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  Buildpack* findById(BuildpackId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Buildpack* findByName(TenantId tenantId, string name)
  {
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.name == name)
        return &e;
    return null;
  }

  Buildpack[] findEnabled(TenantId tenantId)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.enabled)
      .array;
  }

  Buildpack[] findByStack(TenantId tenantId, string stack)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.stack == stack)
      .array;
  }

  void save(Buildpack bp) { store[bp.id] = bp; }
  void update(Buildpack bp) { store[bp.id] = bp; }

  void remove(BuildpackId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
