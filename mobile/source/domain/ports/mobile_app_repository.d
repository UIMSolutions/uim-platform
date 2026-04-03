module uim.platform.xyz.domain.ports.mobile_app_repository;

import uim.platform.xyz.domain.entities.mobile_app;
import uim.platform.xyz.domain.types;

/// Port: outgoing — mobile app persistence.
interface MobileAppRepository
{
    MobileApp findById(MobileAppId id);
    MobileApp[] findByTenant(TenantId tenantId);
    MobileApp[] findByStatus(TenantId tenantId, AppStatus status);
    MobileApp findByBundleId(TenantId tenantId, string bundleId);
    void save(MobileApp app);
    void update(MobileApp app);
    void remove(MobileAppId id);
}
