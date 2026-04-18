module uim.platform.service_manager.domain.ports.repositories.service_instance_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface ServiceInstanceRepository {
    ServiceInstance[] findByTenant(TenantId tenantId);
    ServiceInstance* findById(TenantId tenantId, ServiceInstanceId id);
    void save(ServiceInstance entity);
    void update(ServiceInstance entity);
    void remove(TenantId tenantId, ServiceInstanceId id);
    ulong countByTenant(TenantId tenantId);
}
