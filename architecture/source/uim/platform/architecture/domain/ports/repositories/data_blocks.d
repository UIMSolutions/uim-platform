module uim.platform.architecture.domain.ports.repositories.data_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IDataBlockRepository : ITenantRepository!(DataBlock, DataBlockId) {
     
    size_t countByStatus(TenantId tenantId, LifecycleStatus status); 
    DataBlock[] findByStatus(TenantId tenantId, LifecycleStatus status);
    void removeByStatus(TenantId tenantId, LifecycleStatus status);
    
}
