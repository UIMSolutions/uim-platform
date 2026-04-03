module uim.platform.foundry.infrastructure.persistence.memory.domain;

import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.cf_domain;
import uim.platform.foundry.domain.ports.domain;

// import std.algorithm : filter;
// import std.array : array;

class MemoryDomainRepository : DomainRepository
{
  private CfDomain[DomainId] store;

  CfDomain[] findByOrg(OrgId orgId, TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.ownerOrgId == orgId).array;
  }

  CfDomain* findById(DomainId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  CfDomain* findByName(TenantId tenantId, string name)
  {
    foreach (ref e; store.byValue())
      if (e.tenantId == tenantId && e.name == name)
        return &e;
    return null;
  }

  CfDomain[] findShared(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId
        && e.scope_ == DomainScope.shared_).array;
  }

  CfDomain[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  void save(CfDomain d)
  {
    store[d.id] = d;
  }

  void update(CfDomain d)
  {
    store[d.id] = d;
  }

  void remove(DomainId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
