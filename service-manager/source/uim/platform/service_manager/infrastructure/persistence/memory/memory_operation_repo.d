module uim.platform.service_manager.infrastructure.persistence.memory.memory_operation_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryOperationRepository : OperationRepository {
    private Operation[][string] store;

    Operation[] findByTenant(TenantId tenantId) {
        return store.get(tenantId.value, []);
    }

    Operation* findById(TenantId tenantId, OperationId id) @trusted {
        if (auto items = tenantId.value in store) {
            foreach (ref e; *items)
                if (e.id == id) return &e;
        }
        return null;
    }

    void save(Operation entity) {
        store[entity.tenantId.value] ~= entity;
    }

    void update(Operation entity) {
        if (auto items = entity.tenantId.value in store) {
            foreach (ref e; *items)
                if (e.id == entity.id) { e = entity; return; }
        }
    }

    void remove(TenantId tenantId, OperationId id) {
        if (auto items = tenantId.value in store) {
            import std.algorithm : remove;
            *items = (*items).remove!(e => e.id == id);
        }
    }

    ulong countByTenant(TenantId tenantId) {
        return store.get(tenantId.value, []).length;
    }
}
