module uim.platform.architecture.domain.ports.repositories.business_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IBusinessBlockRepository : ITenantRepository!(BusinessBlock, BusinessBlockId) {
     
    size_t countByStatus(TenantId tenantId, LifecycleStatus status); 
    BusinessBlock[] findByStatus(TenantId tenantId, LifecycleStatus status);
    void removeByStatus(TenantId tenantId, LifecycleStatus status);
    size_t countByDomain(TenantId tenantId, ArchiMateDomain domain);
    BusinessBlock[] findByDomain(TenantId tenantId, ArchiMateDomain domain);
    void removeByDomain(TenantId tenantId, ArchiMateDomain domain);
    
}
