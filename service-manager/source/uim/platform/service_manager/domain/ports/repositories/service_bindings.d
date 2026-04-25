module uim.platform.service_manager.domain.ports.repositories.service_bindings;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface ServiceBindingRepository : ITenantRepository!(ServiceBinding, ServiceBindingId) {

    size_t countByStatus(TenantId tenantId, ServiceBindingStatus status);
    ServiceBinding[] filterByStatus(ServiceBinding[] bindings, ServiceBindingStatus status);
    ServiceBinding[] findByStatus(TenantId tenantId, ServiceBindingStatus status);
    void removeByStatus(TenantId tenantId, ServiceBindingStatus status);
}
