module uim.platform.content_agent.domain.ports.content_package_repository;

import uim.platform.content_agent.domain.entities.content_package;
import uim.platform.content_agent.domain.types;

/// Port: outgoing - content package persistence.
interface ContentPackageRepository
{
    ContentPackage findById(ContentPackageId id);
    ContentPackage[] findByTenant(TenantId tenantId);
    ContentPackage[] findByStatus(TenantId tenantId, PackageStatus status);
    ContentPackage findByName(TenantId tenantId, string name);
    void save(ContentPackage pkg);
    void update(ContentPackage pkg);
    void remove(ContentPackageId id);
}
