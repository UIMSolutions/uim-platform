module infrastructure.persistence.in_memory_system_repo;

import domain.types;
import domain.entities.system_connection;
import domain.ports.system_repository;

import std.algorithm : filter;
import std.array : array;

class InMemorySystemRepository : SystemRepository
{
    private SystemConnection[SystemId] store;

    SystemConnection[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    SystemConnection* findById(SystemId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                return p;
        return null;
    }

    SystemConnection[] findByType(TenantId tenantId, SystemType systemType)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.systemType == systemType)
            .array;
    }

    SystemConnection[] findByStatus(TenantId tenantId, ConnectionStatus status)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.status == status)
            .array;
    }

    void save(SystemConnection system)
    {
        store[system.id] = system;
    }

    void update(SystemConnection system)
    {
        store[system.id] = system;
    }

    void remove(SystemId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                store.remove(id);
    }
}
