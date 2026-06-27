module uim.platform.service_manager.domain.ports.repositories.platforms;

import uim.platform.service_manager;

// mixin(ShowModule!());

@safe:

interface PlatformRepository : ITentRepository!(Platform, PlatformId) {

    size_t countByType(TenantId tenantId, PlatformType type);
    Platform[] findByType(TenantId tenantId, PlatformType type);
    void removeByType(TenantId tenantId, PlatformType type);

    size_t countByStatus(TenantId tenantId, PlatformStatus status);
    Platform[] findByStatus(TenantId tenantId, PlatformStatus status);
    void removeByStatus(TenantId tenantId, PlatformStatus status);
    
}
