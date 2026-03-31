module infrastructure.persistence.in_memory_subaccount_repo;

import domain.types;
import domain.entities.subaccount;
import domain.ports.subaccount_repository;

import std.algorithm : filter;
import std.array : array;

class InMemorySubaccountRepository : SubaccountRepository
{
    private Subaccount[SubaccountId] store;

    Subaccount findById(SubaccountId id)
    {
        if (auto p = id in store)
            return *p;
        return Subaccount.init;
    }

    Subaccount findBySubdomain(string subdomain)
    {
        foreach (ref s; store.byValue())
        {
            if (s.subdomain == subdomain)
                return s;
        }
        return Subaccount.init;
    }

    Subaccount[] findByGlobalAccount(GlobalAccountId globalAccountId)
    {
        return store.byValue().filter!(e => e.globalAccountId == globalAccountId).array;
    }

    Subaccount[] findByDirectory(DirectoryId directoryId)
    {
        return store.byValue().filter!(e => e.parentDirectoryId == directoryId).array;
    }

    Subaccount[] findByRegion(GlobalAccountId globalAccountId, string region)
    {
        return store.byValue()
            .filter!(e => e.globalAccountId == globalAccountId && e.region == region)
            .array;
    }

    Subaccount[] findByStatus(GlobalAccountId globalAccountId, SubaccountStatus status)
    {
        return store.byValue()
            .filter!(e => e.globalAccountId == globalAccountId && e.status == status)
            .array;
    }

    void save(Subaccount sub) { store[sub.id] = sub; }
    void update(Subaccount sub) { store[sub.id] = sub; }
    void remove(SubaccountId id) { store.remove(id); }
}
