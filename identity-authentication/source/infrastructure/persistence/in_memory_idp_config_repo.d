module uim.platform.identity_authentication.infrastructure.persistence.in_memory_idp_config;

import domain.entities.idp_config;
import domain.types;
import domain.ports.idp_config;

import std.algorithm : canFind;

/// In-memory adapter for external IdP configuration persistence.
class InMemoryIdpConfigRepository : IdpConfigRepository
{
    private IdpConfig[string] store;

    IdpConfig findById(string id)
    {
        if (auto p = id in store)
            return *p;
        return IdpConfig.init;
    }

    IdpConfig findDefaultForTenant(TenantId tenantId)
    {
        foreach (c; store.byValue())
        {
            if (c.tenantId == tenantId && c.isDefault)
                return c;
        }
        return IdpConfig.init;
    }

    IdpConfig[] findByTenant(TenantId tenantId)
    {
        IdpConfig[] result;
        foreach (c; store.byValue())
        {
            if (c.tenantId == tenantId)
                result ~= c;
        }
        return result;
    }

    IdpConfig findByDomainHint(TenantId tenantId, string emailDomain)
    {
        foreach (c; store.byValue())
        {
            if (c.tenantId == tenantId && c.domainHints.canFind(emailDomain))
                return c;
        }
        return IdpConfig.init;
    }

    void save(IdpConfig config)
    {
        store[config.id] = config;
    }

    void update(IdpConfig config)
    {
        store[config.id] = config;
    }

    void remove(string id)
    {
        store.remove(id);
    }
}
