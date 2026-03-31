module uim.platform.cloud_foundry.infrastructure.persistence.in_memory_org_repo;

import domain.types;
import domain.entities.organization;
import domain.ports.org_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryOrgRepository : OrgRepository
{
  private Organization[OrgId] store;

  Organization[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  Organization* findById(OrgId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Organization* findByName(TenantId tenantId, string name)
  {
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.name == name)
        return &e;
    return null;
  }

  void save(Organization org) { store[org.id] = org; }
  void update(Organization org) { store[org.id] = org; }

  void remove(OrgId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
