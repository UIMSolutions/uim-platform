module infrastructure.persistence.in_memory_business_user_repo;

import domain.types;
import domain.entities.business_user;
import domain.ports.business_user_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryBusinessUserRepository : BusinessUserRepository
{
    private BusinessUser[BusinessUserId] store;

    BusinessUser* findById(BusinessUserId id)
    {
        if (auto p = id in store)
            return p;
        return null;
    }

    BusinessUser[] findBySystem(SystemInstanceId systemId)
    {
        return store.byValue().filter!(e => e.systemInstanceId == systemId).array;
    }

    BusinessUser[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    BusinessUser* findByUsername(SystemInstanceId systemId, string username)
    {
        foreach (ref e; store.byValue())
            if (e.systemInstanceId == systemId && e.username == username)
                return &store[e.id];
        return null;
    }

    BusinessUser* findByEmail(SystemInstanceId systemId, string email)
    {
        foreach (ref e; store.byValue())
            if (e.systemInstanceId == systemId && e.email == email)
                return &store[e.id];
        return null;
    }

    void save(BusinessUser user) { store[user.id] = user; }
    void update(BusinessUser user) { store[user.id] = user; }
    void remove(BusinessUserId id) { store.remove(id); }
}
