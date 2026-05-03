module uim.platform.service_manager.infrastructure.persistence.memory.memory_service_offering_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryServiceOfferingRepository : TenantRepository!(ServiceOffering, ServiceOfferingId), ServiceOfferingRepository {

    bool existsById(ServiceOfferingId id) {
        return findById(TenantId.init, id) !is null;
    }

    ServiceOffering findById(TenantId tenantId, ServiceOfferingId id) @trusted {
        foreach (e; findByTenant(tenantId))
                if (e.id == id)
                    return e;
        return ServiceOffering.init;
    }

    void removeById(TenantId tenantId, ServiceOfferingId id) {
        remove(findById(tenantId, id));
    }
}
