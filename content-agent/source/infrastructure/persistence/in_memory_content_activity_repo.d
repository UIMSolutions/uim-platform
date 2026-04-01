module infrastructure.persistence.memory.content_activity_repo;

import domain.types;
import domain.entities.content_activity;
import domain.ports.content_activity_repository;

import std.algorithm : filter, sort;
import std.array : array;

class MemoryContentActivityRepository : ContentActivityRepository
{
    private ContentActivity[] store;

    ContentActivity findById(ContentActivityId id)
    {
        foreach (ref e; store)
            if (e.id == id)
                return e;
        return ContentActivity.init;
    }

    ContentActivity[] findByTenant(TenantId tenantId)
    {
        return store.filter!(e => e.tenantId == tenantId).array;
    }

    ContentActivity[] findByEntity(string entityId)
    {
        return store.filter!(e => e.entityId == entityId).array;
    }

    ContentActivity[] findByType(TenantId tenantId, ActivityType activityType)
    {
        return store.filter!(e => e.tenantId == tenantId && e.activityType == activityType).array;
    }

    ContentActivity[] findRecent(TenantId tenantId, int limit)
    {
        auto filtered = store.filter!(e => e.tenantId == tenantId).array;
        filtered.sort!((a, b) => a.timestamp > b.timestamp);
        if (filtered.length > limit)
            return filtered[0 .. limit];
        return filtered;
    }

    void save(ContentActivity activity)
    {
        store ~= activity;
    }
}
