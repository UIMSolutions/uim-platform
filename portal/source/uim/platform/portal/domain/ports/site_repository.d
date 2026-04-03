module uim.platform.xyz.domain.ports.site_repository;

import domain.entities.site;
import domain.types;

/// Port: outgoing — site persistence.
interface SiteRepository
{
    Site findById(SiteId id);
    Site findByAlias(TenantId tenantId, string alias_);
    Site[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
    Site[] findByStatus(TenantId tenantId, SiteStatus status, uint offset = 0, uint limit = 100);
    void save(Site site);
    void update(Site site);
    void remove(SiteId id);
    ulong countByTenant(TenantId tenantId);
}
