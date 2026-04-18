module uim.platform.service_manager.infrastructure.persistence.memory.memory_label_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryLabelRepository : LabelRepository {
    private Label[][string] store;

    Label[] findByTenant(TenantId tenantId) {
        return store.get(tenantId.value, []);
    }

    Label* findById(TenantId tenantId, LabelId id) @trusted {
        if (auto items = tenantId.value in store) {
            foreach (ref e; *items)
                if (e.id == id) return &e;
        }
        return null;
    }

    Label[] findByResource(TenantId tenantId, string resourceType, string resourceId) {
        if (auto items = tenantId.value in store) {
            Label[] result;
            foreach (ref e; *items)
                if (e.resourceType == resourceType && e.resourceId == resourceId)
                    result ~= e;
            return result;
        }
        return null;
    }

    void save(Label entity) {
        store[entity.tenantId.value] ~= entity;
    }

    void update(Label entity) {
        if (auto items = entity.tenantId.value in store) {
            foreach (ref e; *items)
                if (e.id == entity.id) { e = entity; return; }
        }
    }

    void remove(TenantId tenantId, LabelId id) {
        if (auto items = tenantId.value in store) {
            import std.algorithm : remove;
            *items = (*items).remove!(e => e.id == id);
        }
    }

    ulong countByTenant(TenantId tenantId) {
        return store.get(tenantId.value, []).length;
    }
}
