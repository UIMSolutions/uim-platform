module uim.platform.management.infrastructure.persistence.memory.service_plan_repo;

// import uim.platform.management.domain.types;
// import uim.platform.management.domain.entities.service_plan;
// import uim.platform.management.domain.ports.service_plan_repository;

// // import std.algorithm : filter, canFind;
// // import std.array : array;

import uim.platform.management;

mixin(ShowModule!());
@safe:

class MemoryServicePlanRepository : ServicePlanRepository {
    private ServicePlan[ServicePlanId] store;

    ServicePlan findById(ServicePlanId id) {
        if (auto p = id in store)
            return *p;
        return ServicePlan.init;
    }

    ServicePlan[] findByService(string serviceName) {
        return store.byValue().filter!(e => e.serviceName == serviceName).array;
    }

    ServicePlan[] findByCategory(ServicePlanCategory category) {
        return store.byValue().filter!(e => e.category == category).array;
    }

    ServicePlan[] findByRegion(string region) {
        return store.byValue()
            .filter!(e => e.availableRegions.canFind(region))
            .array;
    }

    ServicePlan[] findAll() {
        return store.byValue().array;
    }

    void save(ServicePlan plan) {
        store[plan.id] = plan;
    }

    void update(ServicePlan plan) {
        store[plan.id] = plan;
    }

    void remove(ServicePlanId id) {
        store.remove(id);
    }
}
