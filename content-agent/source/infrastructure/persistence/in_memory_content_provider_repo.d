module infrastructure.persistence.memory.content_provider_repo;

import uim.platform.content_agent.domain.types;
import uim.platform.content_agent.domain.entities.content_provider;
import uim.platform.content_agent.domain.ports.content_provider_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryContentProviderRepository : ContentProviderRepository
{
    private ContentProvider[ContentProviderId] store;

    ContentProvider findById(ContentProviderId id)
    {
        if (auto p = id in store)
            return *p;
        return ContentProvider.init;
    }

    ContentProvider[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    ContentProvider findByName(TenantId tenantId, string name)
    {
        foreach (ref e; store.byValue())
            if (e.tenantId == tenantId && e.name == name)
                return e;
        return ContentProvider.init;
    }

    ContentProvider[] findByStatus(TenantId tenantId, ProviderStatus status)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.status == status)
            .array;
    }

    void save(ContentProvider provider) { store[provider.id] = provider; }
    void update(ContentProvider provider) { store[provider.id] = provider; }
    void remove(ContentProviderId id) { store.remove(id); }
}
