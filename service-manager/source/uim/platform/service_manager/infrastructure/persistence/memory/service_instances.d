module uim.platform.service_manager.infrastructure.persistence.memory.service_instances;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryServiceInstanceRepository : TenantRepository!(ServiceInstance, ServiceInstanceId), ServiceInstanceRepository {

    size_t countByStatus(TenantId tenantId, ServiceInstanceStatus status) {
        return this.findByStatus(tenantId, status).length;
    }

    ServiceInstance[] filterByStatus(ServiceInstance[] instances, ServiceInstanceStatus status) {
        return instances.filter!(i => i.status == status).array;
    }

    ServiceInstance[] findByStatus(TenantId tenantId, ServiceInstanceStatus status) {
        return this.filterByStatus(this.findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, ServiceInstanceStatus status) {
        this.removeAll(this.findByStatus(tenantId, status));
    }
}
