module uim.platform.content_agent.domain.ports.content_provider_repository;

import domain.entities.content_provider;
import domain.types;

/// Port: outgoing - content provider persistence.
interface ContentProviderRepository
{
    ContentProvider findById(ContentProviderId id);
    ContentProvider[] findByTenant(TenantId tenantId);
    ContentProvider findByName(TenantId tenantId, string name);
    ContentProvider[] findByStatus(TenantId tenantId, ProviderStatus status);
    void save(ContentProvider provider);
    void update(ContentProvider provider);
    void remove(ContentProviderId id);
}
