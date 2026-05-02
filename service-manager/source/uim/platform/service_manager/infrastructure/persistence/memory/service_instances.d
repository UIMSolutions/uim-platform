module uim.platform.service_manager.infrastructure.persistence.memory.service_instances;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryServiceInstanceRepository : ServiceInstanceRepository {
    private ServiceInstance[][string] store;

    ServiceInstance[] findByTenant(TenantId tenantId) {
        return store.get(tenantId.value, []);
    }

    ServiceInstance* findById(TenantId tenantId, ServiceInstanceId id) @trusted {
        if (auto items = tenantId.value in store) {
            foreach (ref e; *items)
                if (e.id == id) return &e;
        }
        return null;
    }

    void save(ServiceInstance entity) {
        store[entity.tenantId.value] ~= entity;
    }

    void update(ServiceInstance entity) {
        if (auto items = entity.tenantId.value in store) {
            foreach (ref e; *items)
                if (e.id == entity.id) { e = entity; return; }
        }
    }

    void remove(TenantId tenantId, ServiceInstanceId id) {
        if (auto items = tenantId.value in store) {
            import std.algorithm : remove;
            *items = (items).remove!(e => e.id == id);
        }
    }

    ulong countByTenant(TenantId tenantId) {
        return store.get(tenantId.value, []).length;
    }
}
