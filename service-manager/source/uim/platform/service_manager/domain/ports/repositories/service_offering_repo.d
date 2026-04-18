module uim.platform.service_manager.domain.ports.repositories.service_offering_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

interface ServiceOfferingRepository {
    ServiceOffering[] findByTenant(TenantId tenantId);
    ServiceOffering* findById(TenantId tenantId, ServiceOfferingId id);
    void save(ServiceOffering entity);
    void update(ServiceOffering entity);
    void remove(TenantId tenantId, ServiceOfferingId id);
    ulong countByTenant(TenantId tenantId);
}
