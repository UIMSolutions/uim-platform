module uim.platform.xyz.infrastructure.persistence.memory.role_repo;

import uim.platform.xyz.domain.entities.role;
import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.ports.role_repository;

import std.algorithm : canFind;

class MemoryRoleRepository : RoleRepository
{
    private Role[RoleId] store;

    Role findById(RoleId id)
    {
        if (auto p = id in store)
            return *p;
        return Role.init;
    }

    Role findByName(TenantId tenantId, string name)
    {
        foreach (r; store.byValue())
        {
            if (r.tenantId == tenantId && r.name == name)
                return r;
        }
        return Role.init;
    }

    Role[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100)
    {
        Role[] result;
        uint idx;
        foreach (r; store.byValue())
        {
            if (r.tenantId == tenantId)
            {
                if (idx >= offset && result.length < limit)
                    result ~= r;
                idx++;
            }
        }
        return result;
    }

    Role[] findByUser(string userId)
    {
        Role[] result;
        foreach (r; store.byValue())
        {
            if (r.userIds.canFind(userId))
                result ~= r;
        }
        return result;
    }

    void save(Role role)
    {
        store[role.id] = role;
    }

    void update(Role role)
    {
        store[role.id] = role;
    }

    void remove(RoleId id)
    {
        store.remove(id);
    }
}
