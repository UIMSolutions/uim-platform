module uim.platform.abap_enviroment.infrastructure.persistence.in_memory_business_role_repo;

import uim.platform.abap_enviroment.domain.types;
import uim.platform.abap_enviroment.domain.entities.business_role;
import uim.platform.abap_enviroment.domain.ports.business_role_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryBusinessRoleRepository : BusinessRoleRepository
{
    private BusinessRole[BusinessRoleId] store;

    BusinessRole* findById(BusinessRoleId id)
    {
        if (auto p = id in store)
            return p;
        return null;
    }

    BusinessRole[] findBySystem(SystemInstanceId systemId)
    {
        return store.byValue().filter!(e => e.systemInstanceId == systemId).array;
    }

    BusinessRole[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    BusinessRole* findByName(SystemInstanceId systemId, string name)
    {
        foreach (ref e; store.byValue())
            if (e.systemInstanceId == systemId && e.name == name)
                return &store[e.id];
        return null;
    }

    void save(BusinessRole role) { store[role.id] = role; }
    void update(BusinessRole role) { store[role.id] = role; }
    void remove(BusinessRoleId id) { store.remove(id); }
}
