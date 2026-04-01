module infrastructure.persistence.memory.environment_repo;

import domain.types;
import domain.entities.kyma_environment;
import domain.ports.environment_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryEnvironmentRepository : EnvironmentRepository
{
    private KymaEnvironment[KymaEnvironmentId] store;

    KymaEnvironment findById(KymaEnvironmentId id)
    {
        if (auto p = id in store)
            return *p;
        return KymaEnvironment.init;
    }

    KymaEnvironment[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    KymaEnvironment[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.subaccountId == subaccountId)
            .array;
    }

    KymaEnvironment[] findByStatus(EnvironmentStatus status)
    {
        return store.byValue().filter!(e => e.status == status).array;
    }

    void save(KymaEnvironment env) { store[env.id] = env; }
    void update(KymaEnvironment env) { store[env.id] = env; }
    void remove(KymaEnvironmentId id) { store.remove(id); }
}
