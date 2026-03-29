module uim.platform.identity_authentication.infrastructure.persistence.in_memory_group;

import domain.entities.group;
import domain.types;
import domain.ports.group;

/// In-memory adapter for group persistence.
class InMemoryGroupRepository : GroupRepository
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
