module infrastructure.persistence.memory.global_account_repo;

import domain.types;
import domain.entities.global_account;
import domain.ports.global_account_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryGlobalAccountRepository : GlobalAccountRepository
{
    private GlobalAccount[GlobalAccountId] store;

    GlobalAccount findById(GlobalAccountId id)
    {
        if (auto p = id in store)
            return *p;
        return GlobalAccount.init;
    }

    GlobalAccount[] findByStatus(GlobalAccountStatus status)
    {
        return store.byValue().filter!(e => e.status == status).array;
    }

    GlobalAccount[] findAll()
    {
        return store.byValue().array;
    }

    void save(GlobalAccount account) { store[account.id] = account; }
    void update(GlobalAccount account) { store[account.id] = account; }
    void remove(GlobalAccountId id) { store.remove(id); }
}
