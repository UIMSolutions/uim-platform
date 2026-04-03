module uim.platform.object_store.infrastructure.persistence.memory.lifecycle_rule;

import uim.platform.object_store.domain.types;
import uim.platform.object_store.domain.entities.lifecycle_rule;
import uim.platform.object_store.domain.ports.repositories.lifecycle_rule;

// import std.algorithm : filter;
// import std.array : array;

class MemoryLifecycleRuleRepository : LifecycleRuleRepository
{
    private LifecycleRule[LifecycleRuleId] store;

    LifecycleRule findById(LifecycleRuleId id)
    {
        if (auto p = id in store)
            return *p;
        return null;
    }

    LifecycleRule[] findByBucket(BucketId bucketId)
    {
        return store.byValue().filter!(e => e.bucketId == bucketId).array;
    }

    void save(LifecycleRule entity) { store[entity.id] = entity; }
    void update(LifecycleRule entity) { store[entity.id] = entity; }
    void remove(LifecycleRuleId id) { store.remove(id); }
}
