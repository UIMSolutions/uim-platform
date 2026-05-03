module uim.platform.service_manager.infrastructure.persistence.memory.memory_platform_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryPlatformRepository : TenantRepository!(Platform, PlatformId), PlatformRepository {
    
    // TODO
    
}
