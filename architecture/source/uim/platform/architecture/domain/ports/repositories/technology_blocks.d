module uim.platform.architecture.domain.ports.repositories.technology_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface ITechnologyBlockRepository : ITenantRepository!(TechnologyBlock, TechnologyBlockId) {
     
    size_t countByStatus(TenantId tenantId, LifecycleStatus status); 
    TechnologyBlock[] findByStatus(TenantId tenantId, LifecycleStatus status);
    void removeByStatus(TenantId tenantId, LifecycleStatus status);
    
}
