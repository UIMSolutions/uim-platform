module uim.platform.architecture.domain.ports.repositories.architecture_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IArchitectureBlockRepository : ITenantRepository!(ArchitectureBlock, ArchitectureBlockId) {
     
    size_t countByStatus(TenantId tenantId, LifecycleStatus status); 
    ArchitectureBlock[] findByStatus(TenantId tenantId, LifecycleStatus status);
    void removeByStatus(TenantId tenantId, LifecycleStatus status);
    size_t countByDomain(TenantId tenantId, ArchiMateDomain domain);
    ArchitectureBlock[] findByDomain(TenantId tenantId, ArchiMateDomain domain);
    void removeByDomain(TenantId tenantId, ArchiMateDomain domain);
    
}
