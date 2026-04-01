module uim.platform.object_store.infrastructure.persistence.memory.cors_rule;

import uim.platform.object_store.domain.types;
import uim.platform.object_store.domain.entities.cors_rule;
import uim.platform.object_store.domain.ports.repositories.cors_rule;

import std.algorithm : filter;
import std.array : array;

class MemoryCorsRuleRepository : CorsRuleRepository {
    private CorsRule[CorsRuleId] store;

    CorsRule findById(CorsRuleId id) {
        if (auto p = id in store)
            return *p;
        return null;
    }

    CorsRule[] findByBucket(BucketId bucketId) {
        return store.byValue().filter!(e => e.bucketId == bucketId).array;
    }

    void save(CorsRule entity) {
        store[entity.id] = entity;
    }

    void update(CorsRule entity) {
        store[entity.id] = entity;
    }

    void remove(CorsRuleId id) {
        store.remove(id);
    }
}
