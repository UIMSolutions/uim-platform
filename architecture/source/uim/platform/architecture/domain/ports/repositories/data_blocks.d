module uim.platform.architecture.domain.ports.repositories.data_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IDataBlockRepository : ITenantRepository!(DataBlock, DataBlockId) {
     
    size_t countByStatus(TenantId tenantId, LifecycleStatus status); 
    DataBlock[] findByStatus(TenantId tenantId, LifecycleStatus status);
    void removeByStatus(TenantId tenantId, LifecycleStatus status);
    size_t countByDomain(TenantId tenantId, ArchiMateDomain domain);
    DataBlock[] findByDomain(TenantId tenantId, ArchiMateDomain domain);
    void removeByDomain(TenantId tenantId, ArchiMateDomain domain);
    size_t countByAspect(TenantId tenantId, ArchiMateAspect aspect);
    DataBlock[] findByAspect(TenantId tenantId, ArchiMateAspect aspect);
    void removeByAspect(TenantId tenantId, ArchiMateAspect aspect);
    
}
