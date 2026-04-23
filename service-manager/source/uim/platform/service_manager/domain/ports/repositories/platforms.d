module uim.platform.service_manager.domain.ports.repositories.platforms;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface PlatformRepository {
    Platform[] findByTenant(TenantId tenantId);
    Platform* findById(TenantId tenantId, PlatformId id);
    void save(Platform entity);
    void update(Platform entity);
    void remove(TenantId tenantId, PlatformId id);
    ulong countByTenant(TenantId tenantId);
}
