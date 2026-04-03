module uim.platform.portal.domain.ports.provider_repository;

import uim.platform.portal.domain.entities.content_provider;
import uim.platform.portal.domain.types;

/// Port: outgoing — content provider persistence.
interface ProviderRepository
{
    ContentProvider findById(ProviderId id);
    ContentProvider[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
    void save(ContentProvider provider);
    void update(ContentProvider provider);
    void remove(ProviderId id);
}
