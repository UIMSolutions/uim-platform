module uim.platform.architecture.domain.ports.repositories.solution_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface ISolutionBlockRepository : ITenantRepository!(SolutionBlock, SolutionBlockId) {
     
    size_t countByStatus(TenantId tenantId, LifecycleStatus status); 
    SolutionBlock[] findByStatus(TenantId tenantId, LifecycleStatus status);
    void removeByStatus(TenantId tenantId, LifecycleStatus status);
    size_t countByDomain(TenantId tenantId, ArchiMateDomain domain);
    SolutionBlock[] findByDomain(TenantId tenantId, ArchiMateDomain domain);
    void removeByDomain(TenantId tenantId, ArchiMateDomain domain);
    size_t countByAspect(TenantId tenantId, ArchiMateAspect aspect);
    SolutionBlock[] findByAspect(TenantId tenantId, ArchiMateAspect aspect);
    void removeByAspect(TenantId tenantId, ArchiMateAspect aspect);
    
}
