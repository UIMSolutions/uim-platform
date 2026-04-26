module uim.platform.service_manager.domain.ports.repositories.service_offerings;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface ServiceOfferingRepository : ITenantRepository!(ServiceOffering, ServiceOfferingId) {
    
    size_t countByStatus(TenantId tenantId, ServiceOfferingStatus status);
    ServiceOffering[] filterByStatus(ServiceOffering[] offerings, ServiceOfferingStatus status);
    ServiceOffering[] findByStatus(TenantId tenantId, ServiceOfferingStatus status);
    void removeByStatus(TenantId tenantId, ServiceOfferingStatus status);
    
}
