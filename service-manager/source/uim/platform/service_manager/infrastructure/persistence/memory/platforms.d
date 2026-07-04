module uim.platform.service_manager.infrastructure.persistence.memory.platforms;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryPlatformRepository : TenantRepository!(Platform, PlatformId), PlatformRepository {
    
    size_t countByType(TenantId tenantId, PlatformType type) {
        return this.findByType(tenantId, type).length;
    }
    Platform[] filterByType(Platform[] platforms, PlatformType type) {
        return platforms.filter!(p => p.type == type).array;
    }
    Platform[] findByType(TenantId tenantId, PlatformType type) {
        return this.filterByType(this.findByTenant(tenantId), type);
    }
    void removeByType(TenantId tenantId, PlatformType type) {
        this.removeAll(this.findByType(tenantId, type));
    }

    size_t countByStatus(TenantId tenantId, PlatformStatus status) {
        return this.findByStatus(tenantId, status).length;
    }
    Platform[] filterByStatus(Platform[] platforms, PlatformStatus status) {
        return platforms.filter!(p => p.status == status).array;
    }
    Platform[] findByStatus(TenantId tenantId, PlatformStatus status) {
        return this.filterByStatus(this.findByTenant(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, PlatformStatus status) {
        this.removeAll(this.findByStatus(tenantId, status));
    }
    
}
