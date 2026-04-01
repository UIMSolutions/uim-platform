module uim.platform.abap_enviroment.infrastructure.persistence.in_memory_system_instance_repo;

import uim.platform.abap_enviroment.domain.types;
import uim.platform.abap_enviroment.domain.entities.system_instance;
import uim.platform.abap_enviroment.domain.ports.system_instance_repository;

import std.algorithm : filter;
import std.array : array;

class InMemorySystemInstanceRepository : SystemInstanceRepository
{
    private SystemInstance[SystemInstanceId] store;

    SystemInstance* findById(SystemInstanceId id)
    {
        if (auto p = id in store)
            return p;
        return null;
    }

    SystemInstance[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    SystemInstance* findByName(TenantId tenantId, string name)
    {
        foreach (ref e; store.byValue())
            if (e.tenantId == tenantId && e.name == name)
                return &store[e.id];
        return null;
    }

    SystemInstance[] findByStatus(TenantId tenantId, SystemStatus status)
    {
        return store.byValue()
            .filter!(e => e.tenantId == tenantId && e.status == status)
            .array;
    }

    void save(SystemInstance instance) { store[instance.id] = instance; }
    void update(SystemInstance instance) { store[instance.id] = instance; }
    void remove(SystemInstanceId id) { store.remove(id); }
}
