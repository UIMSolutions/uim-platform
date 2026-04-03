module uim.platform.xyz.domain.ports.provider_repository;

import domain.entities.content_provider;
import domain.types;

/// Port: outgoing — content provider persistence.
interface ProviderRepository
{
    ContentProvider findById(ProviderId id);
    ContentProvider[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
    void save(ContentProvider provider);
    void update(ContentProvider provider);
    void remove(ProviderId id);
}
