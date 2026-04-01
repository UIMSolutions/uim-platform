module uim.platform.identity_authentication.infrastructure.persistence.memory.group;

import uim.platform.identity_authentication.domain.entities.group;
import uim.platform.identity_authentication.domain.types;
import uim.platform.identity_authentication.domain.ports.group;

/// In-memory adapter for group persistence.
class MemoryGroupRepository : GroupRepository
{
    private Group[GroupId] store;

    Group findById(GroupId id)
    {
        if (auto p = id in store)
            return *p;
        return Group.init;
    }

    Group[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100)
    {
        Group[] result;
        uint idx;
        foreach (g; store.byValue())
        {
            if (g.tenantId == tenantId)
            {
                if (idx >= offset && result.length < limit)
                    result ~= g;
                idx++;
            }
        }
        return result;
    }

    void save(Group group)
    {
        store[group.id] = group;
    }

    void update(Group group)
    {
        store[group.id] = group;
    }

    void remove(GroupId id)
    {
        store.remove(id);
    }
}
