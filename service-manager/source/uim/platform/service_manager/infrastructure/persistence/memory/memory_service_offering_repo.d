module uim.platform.service_manager.infrastructure.persistence.memory.memory_service_offering_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryServiceOfferingRepository : ServiceOfferingRepository {
    private ServiceOffering[][string] store;

    ServiceOffering[] findByTenant(TenantId tenantId) {
        return store.get(tenantId.value, []);
    }

    ServiceOffering* findById(TenantId tenantId, ServiceOfferingId id) {
        auto items = store.get(tenantId.value, []);
        foreach (ref e; items)
            if (e.id == id) return &e;
        return null;
    }

    void save(ServiceOffering entity) {
        store[entity.tenantId.value] ~= entity;
    }

    void update(ServiceOffering entity) {
        if (auto items = entity.tenantId.value in store) {
            foreach (ref e; *items)
                if (e.id == entity.id) { e = entity; return; }
        }
    }

    void remove(TenantId tenantId, ServiceOfferingId id) {
        if (auto items = tenantId.value in store) {
            import std.algorithm : remove;
            *items = (*items).remove!(e => e.id == id);
        }
    }

    ulong countByTenant(TenantId tenantId) {
        return store.get(tenantId.value, []).length;
    }
}
