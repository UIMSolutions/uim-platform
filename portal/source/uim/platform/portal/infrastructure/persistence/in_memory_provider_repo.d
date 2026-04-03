module uim.platform.xyz.infrastructure.persistence.memory.provider_repo;

import domain.entities.content_provider;
import domain.types;
import domain.ports.provider_repository;

class MemoryProviderRepository : ProviderRepository
{
    private ContentProvider[ProviderId] store;

    ContentProvider findById(ProviderId id)
    {
        if (auto p = id in store)
            return *p;
        return ContentProvider.init;
    }

    ContentProvider[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100)
    {
        ContentProvider[] result;
        uint idx;
        foreach (cp; store.byValue())
        {
            if (cp.tenantId == tenantId)
            {
                if (idx >= offset && result.length < limit)
                    result ~= cp;
                idx++;
            }
        }
        return result;
    }

    void save(ContentProvider provider)
    {
        store[provider.id] = provider;
    }

    void update(ContentProvider provider)
    {
        store[provider.id] = provider;
    }

    void remove(ProviderId id)
    {
        store.remove(id);
    }
}
