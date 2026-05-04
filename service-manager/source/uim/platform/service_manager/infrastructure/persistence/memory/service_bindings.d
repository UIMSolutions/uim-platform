module uim.platform.service_manager.infrastructure.persistence.memory.service_bindings;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryServiceBindingRepository : TenantRepository!(ServiceBinding, ServiceBindingId), ServiceBindingRepository {

    size_t countByStatus(TenantId tenantId, ServiceBindingStatus status) {
        return this.findByStatus(tenantId, status).length;
    }
    ServiceBinding[] filterByStatus(ServiceBinding[] bindings, ServiceBindingStatus status) {
        return bindings.filter!(b => b.status == status).array;
    }
    ServiceBinding[] findByStatus(TenantId tenantId, ServiceBindingStatus status) {
        return this.filterByStatus(this.findByTenant(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, ServiceBindingStatus status)     {
        this.removeAll(this.findByStatus(tenantId, status));
    }

}
