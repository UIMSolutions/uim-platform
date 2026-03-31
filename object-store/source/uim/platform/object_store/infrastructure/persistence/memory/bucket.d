module uim.platform.object_store.infrastructure.persistence.memory.bucket_repo;

import domain.types;
import domain.entities.bucket;
import domain.ports.bucket_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryBucketRepository : BucketRepository
{
    private Bucket[BucketId] store;

    Bucket findById(BucketId id)
    {
        if (auto p = id in store)
            return *p;
        return null;
    }

    Bucket findByName(TenantId tenantId, string name)
    {
        foreach (ref e; store.byValue())
            if (e.tenantId == tenantId && e.name == name)
                return e;
        return null;
    }

    Bucket[] findByTenant(TenantId tenantId)
    {
        return store.byValue().filter!(e => e.tenantId == tenantId).array;
    }

    void save(Bucket entity) { store[entity.id] = entity; }
    void update(Bucket entity) { store[entity.id] = entity; }
    void remove(BucketId id) { store.remove(id); }
}
