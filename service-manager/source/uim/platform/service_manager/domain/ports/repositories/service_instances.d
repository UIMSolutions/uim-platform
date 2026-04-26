module uim.platform.service_manager.domain.ports.repositories.service_instances;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface ServiceInstanceRepository : ITenantRepository!(ServiceInstance, ServiceInstanceId) {

    size_t countByStatus(TenantId tenantId, ServiceInstanceStatus status);
    ServiceInstance[] filterByStatus(ServiceInstance[] instances, ServiceInstanceStatus status);
    ServiceInstance[] findByStatus(TenantId tenantId, ServiceInstanceStatus status);
    void removeByStatus(TenantId tenantId, ServiceInstanceStatus status);
    
}
