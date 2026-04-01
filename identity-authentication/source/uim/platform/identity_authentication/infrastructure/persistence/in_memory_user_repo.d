module uim.platform.identity_authentication.infrastructure.persistence.memory.user;

import uim.platform.identity_authentication.domain.entities.user;
import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication.domain.ports.user;

/// In-memory adapter for user persistence (swap for DB adapter in production).
class MemoryUserRepository : UserRepository
{
    private User[UserId] store;

    User findById(UserId id)
    {
        if (auto p = id in store)
            return *p;
        return User.init;
    }

    User findByEmail(TenantId tenantId, string email)
    {
        foreach (u; store.byValue())
        {
            if (u.tenantId == tenantId && u.email == email)
                return u;
        }
        return User.init;
    }

    User findByUserName(TenantId tenantId, string userName)
    {
        foreach (u; store.byValue())
        {
            if (u.tenantId == tenantId && u.userName == userName)
                return u;
        }
        return User.init;
    }

    User[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100)
    {
        User[] result;
        uint idx;
        foreach (u; store.byValue())
        {
            if (u.tenantId == tenantId)
            {
                if (idx >= offset && result.length < limit)
                    result ~= u;
                idx++;
            }
        }
        return result;
    }

    User[] findByGroupId(GroupId groupId)
    {
        import std.algorithm : canFind;
        User[] result;
        foreach (u; store.byValue())
        {
            if (u.groupIds.canFind(groupId))
                result ~= u;
        }
        return result;
    }

    void save(User user)
    {
        store[user.id] = user;
    }

    void update(User user)
    {
        store[user.id] = user;
    }

    void remove(UserId id)
    {
        store.remove(id);
    }

    ulong countByTenant(TenantId tenantId)
    {
        ulong count;
        foreach (u; store.byValue())
        {
            if (u.tenantId == tenantId)
                count++;
        }
        return count;
    }
}
