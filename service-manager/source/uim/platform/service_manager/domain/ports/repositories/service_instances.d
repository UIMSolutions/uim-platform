module uim.platform.service_manager.domain.ports.repositories.service_instances;

import uim.platform.service_manager;

// mixin(ShowModule!());

@safe:

interface ServiceInstanceRepository : ITentRepository!(ServiceInstance, ServiceInstanceId) {

    size_t countByStatus(TenantId tenantId, ServiceInstanceStatus status);
    ServiceInstance[] findByStatus(TenantId tenantId, ServiceInstanceStatus status);
    void removeByStatus(TenantId tenantId, ServiceInstanceStatus status);
    
}
