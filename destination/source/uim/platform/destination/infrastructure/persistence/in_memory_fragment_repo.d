module uim.platform.destination.infrastructure.persistence.memory.fragment_repo;

import uim.platform.destination.domain.types;
import uim.platform.destination.domain.entities.destination_fragment;
import uim.platform.destination.domain.ports.fragment_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryFragmentRepository : FragmentRepository
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
