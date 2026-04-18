module uim.platform.service_manager.infrastructure.persistence.memory.memory_service_plan_repo;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class MemoryServicePlanRepository : ServicePlanRepository {
    private ServicePlan[][string] store;

    ServicePlan[] findByTenant(TenantId tenantId) {
        return store.get(tenantId.value, []);
    }

    ServicePlan* findById(TenantId tenantId, ServicePlanId id) {
        auto items = store.get(tenantId.value, []);
        foreach (ref e; items)
            if (e.id == id) return &e;
        return null;
    }

    void save(ServicePlan entity) {
        store[entity.tenantId.value] ~= entity;
    }

    void update(ServicePlan entity) {
        if (auto items = entity.tenantId.value in store) {
            foreach (ref e; *items)
                if (e.id == entity.id) { e = entity; return; }
        }
    }

    void remove(TenantId tenantId, ServicePlanId id) {
        if (auto items = tenantId.value in store) {
            import std.algorithm : remove;
            *items = (*items).remove!(e => e.id == id);
        }
    }

    ulong countByTenant(TenantId tenantId) {
        return store.get(tenantId.value, []).length;
    }
}
