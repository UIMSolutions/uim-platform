module uim.platform.architecture.domain.ports.repositories.technology_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface ITechnologyBlockRepository : ITenantRepository!(TechnologyBlock, TechnologyBlockId) {
     
    size_t countByStatus(TenantId tenantId, LifecycleStatus status); 
    TechnologyBlock[] findByStatus(TenantId tenantId, LifecycleStatus status);
    void removeByStatus(TenantId tenantId, LifecycleStatus status);
    size_t countByDomain(TenantId tenantId, ArchiMateDomain domain);
    TechnologyBlock[] findByDomain(TenantId tenantId, ArchiMateDomain domain);
    void removeByDomain(TenantId tenantId, ArchiMateDomain domain);
    size_t countByAspect(TenantId tenantId, ArchiMateAspect aspect);
    TechnologyBlock[] findByAspect(TenantId tenantId, ArchiMateAspect aspect);
    void removeByAspect(TenantId tenantId, ArchiMateAspect aspect);
    
}
