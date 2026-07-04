module uim.platform.service_manager.infrastructure.persistence.memory.service_offerings;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryServiceOfferingRepository : TenantRepository!(ServiceOffering, ServiceOfferingId), ServiceOfferingRepository {

    size_t countByStatus(TenantId tenantId, ServiceOfferingStatus status) {
        return this.findByStatus(tenantId, status).length;
    }

    ServiceOffering[] filterByStatus(ServiceOffering[] offerings, ServiceOfferingStatus status) {
        return offerings.filter!(o => o.status == status).array;
    }

    ServiceOffering[] findByStatus(TenantId tenantId, ServiceOfferingStatus status) {
        return this.filterByStatus(this.findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, ServiceOfferingStatus status) {
        this.removeAll(this.findByStatus(tenantId, status));
    }
}
