module infrastructure.persistence.memory.service_plan_repo;

import domain.types;
import domain.entities.service_plan;
import domain.ports.service_plan_repository;

import std.algorithm : filter, canFind;
import std.array : array;

class InMemoryServicePlanRepository : ServicePlanRepository
{
    private ServicePlan[ServicePlanId] store;

    ServicePlan findById(ServicePlanId id)
    {
        if (auto p = id in store)
            return *p;
        return ServicePlan.init;
    }

    ServicePlan[] findByService(string serviceName)
    {
        return store.byValue().filter!(e => e.serviceName == serviceName).array;
    }

    ServicePlan[] findByCategory(ServicePlanCategory category)
    {
        return store.byValue().filter!(e => e.category == category).array;
    }

    ServicePlan[] findByRegion(string region)
    {
        return store.byValue()
            .filter!(e => e.availableRegions.canFind(region))
            .array;
    }

    ServicePlan[] findAll()
    {
        return store.byValue().array;
    }

    void save(ServicePlan plan) { store[plan.id] = plan; }
    void update(ServicePlan plan) { store[plan.id] = plan; }
    void remove(ServicePlanId id) { store.remove(id); }
}
