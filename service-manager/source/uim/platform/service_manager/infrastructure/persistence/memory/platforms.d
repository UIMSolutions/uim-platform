module uim.platform.service_manager.infrastructure.persistence.memory.memory_platform_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryPlatformRepository :TenantRepository!(Platform, PlatformId), PlatformRepository {
    private Platform[][string] store;

    Platform[] findByTenant(TenantId tenantId) {
        return store.get(tenantId.value, []);
    }

    Platform findById(TenantId tenantId, PlatformId id) @trusted {
        if (auto items = tenantId.value in store) {
            foreach (ref e; *items)
                if (e.id == id) return &e;
        }
        return null;
    }

    void save(Platform entity) {
        store[entity.tenantId.value] ~= entity;
    }

    void update(Platform entity) {
        if (auto items = entity.tenantId.value in store) {
            foreach (ref e; *items)
                if (e.id == entity.id) { e = entity; return; }
        }
    }

    void remove(TenantId tenantId, PlatformId id) {
        if (auto items = tenantId.value in store) {
            import std.algorithm : remove;
            *items = (items).remove!(e => e.id == id);
        }
    }

    ulong countByTenant(TenantId tenantId) {
        return store.get(tenantId.value, []).length;
    }
}
