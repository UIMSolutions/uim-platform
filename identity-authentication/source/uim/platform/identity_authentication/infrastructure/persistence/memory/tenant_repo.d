module uim.platform.identity_authentication.infrastructure.persistence.memory.tenant_repo;

// import uim.platform.identity_authentication.domain.entities.tenant;
// import uim.platform.identity_authentication.domain.types;
// import uim.platform.identity_authentication.domain.ports.tenant;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:
/// In-memory adapter for tenant persistence.
class MemoryTenantRepository : TenantRepository
{
  private Tenant[TenantId] store;

  bool existsById(TenantId id)
  {
    return (id in store) ? true : false;
  }

  Tenant findById(TenantId id)
  {
    if (existsById(id))
      return store[id];
    return Tenant.init;
  }

  Tenant findBySubdomain(string subdomain)
  {
    foreach (t; store.byValue())
    {
      if (t.subdomain == subdomain)
        return t;
    }
    return Tenant.init;
  }

  Tenant[] findAll(uint offset = 0, uint limit = 100)
  {
    Tenant[] result;
    uint idx;
    foreach (t; store.byValue())
    {
      if (idx >= offset && result.length < limit)
        result ~= t;
      idx++;
    }
    return result;
  }

  void save(Tenant tenant)
  {
    store[tenant.id] = tenant;
  }

  void update(Tenant tenant)
  {
    store[tenant.id] = tenant;
  }

  void remove(TenantId id)
  {
    store.remove(id);
  }
}
