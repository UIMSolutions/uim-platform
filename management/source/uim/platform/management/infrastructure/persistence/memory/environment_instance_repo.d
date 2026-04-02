module uim.platform.management.infrastructure.persistence.memory.environment_instance_repo;

import uim.platform.management.domain.types;
import uim.platform.management.domain.entities.environment_instance;
import uim.platform.management.domain.ports.environment_instance_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryEnvironmentInstanceRepository : EnvironmentInstanceRepository
{
    private EnvironmentInstance[EnvironmentInstanceId] store;

    EnvironmentInstance findById(EnvironmentInstanceId id)
    {
        if (auto p = id in store)
            return *p;
        return EnvironmentInstance.init;
    }

    EnvironmentInstance[] findBySubaccount(SubaccountId subaccountId)
    {
        return store.byValue().filter!(e => e.subaccountId == subaccountId).array;
    }

    EnvironmentInstance[] findByType(SubaccountId subaccountId, EnvironmentType envType)
    {
        return store.byValue()
            .filter!(e => e.subaccountId == subaccountId && e.environmentType == envType)
            .array;
    }

    EnvironmentInstance[] findByStatus(SubaccountId subaccountId, EnvironmentStatus status)
    {
        return store.byValue()
            .filter!(e => e.subaccountId == subaccountId && e.status == status)
            .array;
    }

    void save(EnvironmentInstance inst) { store[inst.id] = inst; }
    void update(EnvironmentInstance inst) { store[inst.id] = inst; }
    void remove(EnvironmentInstanceId id) { store.remove(id); }
}
