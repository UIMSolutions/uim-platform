module infrastructure.persistence.in_memory_fragment_repo;

import domain.types;
import domain.entities.destination_fragment;
import domain.ports.fragment_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryFragmentRepository : FragmentRepository
{
    private DestinationFragment[FragmentId] store;

    DestinationFragment findById(FragmentId id)
    {
        if (auto p = id in store)
            return *p;
        return DestinationFragment.init;
    }

    DestinationFragment findByName(TenantId tenantId, SubaccountId subaccountId, string name)
    {
        foreach (ref e; store.byValue())
            if (e.tenantId == tenantId && e.subaccountId == subaccountId && e.name == name)
                return e;
        return DestinationFragment.init;
    }

    DestinationFragment[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    DestinationFragment[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.subaccountId == subaccountId)
            .array;
    }

    void save(DestinationFragment fragment) { store[fragment.id] = fragment; }
    void update(DestinationFragment fragment) { store[fragment.id] = fragment; }
    void remove(FragmentId id) { store.remove(id); }
}
