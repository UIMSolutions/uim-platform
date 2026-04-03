module uim.platform.foundry.infrastructure.persistence.memory.org;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.organization;
import uim.platform.foundry.domain.ports.org;

// import std.algorithm : filter;
// import std.array : array;

class MemoryOrgRepository : OrgRepository
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
