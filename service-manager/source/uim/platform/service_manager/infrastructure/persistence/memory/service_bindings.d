module uim.platform.service_manager.infrastructure.persistence.memory.memory_service_binding_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryServiceBindingRepository : TenantRepository!(ServiceBinding, ServiceBindingId), ServiceBindingRepository {
    private ServiceBinding[][string] store;

    ServiceBinding[] findByTenant(TenantId tenantId) {
        return store.get(tenantId.value, []);
    }

    ServiceBinding findById(TenantId tenantId, ServiceBindingId id) @trusted {
        if (auto items = tenantId.value in store) {
            foreach (ref e; *items)
                if (e.id == id) return &e;
        }
        return null;
    }

    void save(ServiceBinding entity) {
        store[entity.tenantId.value] ~= entity;
    }

    void update(ServiceBinding entity) {
        if (auto items = entity.tenantId.value in store) {
            foreach (ref e; *items)
                if (e.id == entity.id) { e = entity; return; }
        }
    }

    void remove(TenantId tenantId, ServiceBindingId id) {
        if (auto items = tenantId.value in store) {
            import std.algorithm : remove;
            *items = (items).remove!(e => e.id == id);
        }
    }

    ulong countByTenant(TenantId tenantId) {
        return store.get(tenantId.value, []).length;
    }
}
