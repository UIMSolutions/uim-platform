module uim.platform.portal.domain.ports.catalog_repository;

import uim.platform.portal.domain.entities.catalog;
import uim.platform.portal.domain.types;

/// Port: outgoing — catalog persistence.
interface CatalogRepository
{
    Catalog findById(CatalogId id);
    Catalog[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
    Catalog[] findByProvider(ProviderId providerId);
    void save(Catalog catalog);
    void update(Catalog catalog);
    void remove(CatalogId id);
}
