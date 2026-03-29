module uim.platform.identity_authentication.infrastructure.persistence.in_memory_tenant;

import domain.entities.tenant;
import domain.types;
import domain.ports.tenant;

/// In-memory adapter for tenant persistence.
class InMemoryTenantRepository : TenantRepository
{
    private Tenant[TenantId] store;

    Tenant findById(TenantId id)
    {
        if (auto p = id in store)
            return *p;
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
