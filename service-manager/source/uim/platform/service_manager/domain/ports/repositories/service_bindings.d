module uim.platform.service_manager.domain.ports.repositories.service_bindings;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface ServiceBindingRepository {
    ServiceBinding[] findByTenant(TenantId tenantId);
    ServiceBinding* findById(TenantId tenantId, ServiceBindingId id);
    void save(ServiceBinding entity);
    void update(ServiceBinding entity);
    void remove(TenantId tenantId, ServiceBindingId id);
    ulong countByTenant(TenantId tenantId);
}
