module infrastructure.persistence.memory.entitlement_repo;

import domain.types;
import domain.entities.entitlement;
import domain.ports.entitlement_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryEntitlementRepository : EntitlementRepository
{
    private Entitlement[EntitlementId] store;

    Entitlement findById(EntitlementId id)
    {
        if (auto p = id in store)
            return *p;
        return Entitlement.init;
    }

    Entitlement[] findByGlobalAccount(GlobalAccountId globalAccountId)
    {
        return store.byValue().filter!(e => e.globalAccountId == globalAccountId).array;
    }

    Entitlement[] findBySubaccount(SubaccountId subaccountId)
    {
        return store.byValue().filter!(e => e.subaccountId == subaccountId).array;
    }

    Entitlement[] findByDirectory(DirectoryId directoryId)
    {
        return store.byValue().filter!(e => e.directoryId == directoryId).array;
    }

    Entitlement[] findByServicePlan(GlobalAccountId globalAccountId, ServicePlanId planId)
    {
        return store.byValue()
            .filter!(e => e.globalAccountId == globalAccountId && e.servicePlanId == planId)
            .array;
    }

    void save(Entitlement ent) { store[ent.id] = ent; }
    void update(Entitlement ent) { store[ent.id] = ent; }
    void remove(EntitlementId id) { store.remove(id); }
}
