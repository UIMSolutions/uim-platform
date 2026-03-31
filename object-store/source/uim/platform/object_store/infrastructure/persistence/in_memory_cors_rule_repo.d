module infrastructure.persistence.in_memory_cors_rule_repo;

import domain.types;
import domain.entities.cors_rule;
import domain.ports.cors_rule_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryCorsRuleRepository : CorsRuleRepository
{
    private CorsRule[CorsRuleId] store;

    CorsRule findById(CorsRuleId id)
    {
        if (auto p = id in store)
            return *p;
        return null;
    }

    CorsRule[] findByBucket(BucketId bucketId)
    {
        return store.byValue().filter!(e => e.bucketId == bucketId).array;
    }

    void save(CorsRule entity) { store[entity.id] = entity; }
    void update(CorsRule entity) { store[entity.id] = entity; }
    void remove(CorsRuleId id) { store.remove(id); }
}
