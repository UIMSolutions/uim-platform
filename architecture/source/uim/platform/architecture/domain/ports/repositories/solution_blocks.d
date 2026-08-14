module uim.platform.architecture.domain.ports.repositories.solution_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface ISolutionBlockRepository : ITenantRepository!(SolutionBlock, SolutionBlockId) {
     
    size_t countByStatus(TenantId tenantId, LifecycleStatus status); 
    SolutionBlock[] findByStatus(TenantId tenantId, LifecycleStatus status);
    void removeByStatus(TenantId tenantId, LifecycleStatus status);
    
}
