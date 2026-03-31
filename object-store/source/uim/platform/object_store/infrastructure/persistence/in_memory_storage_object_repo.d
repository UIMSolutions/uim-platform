module infrastructure.persistence.in_memory_storage_object_repo;

import domain.types;
import domain.entities.storage_object;
import domain.ports.storage_object_repository;

import std.algorithm : filter, startsWith;
import std.array : array;

class InMemoryStorageObjectRepository : StorageObjectRepository
{
    private StorageObject[ObjectId] store;

    StorageObject findById(ObjectId id)
    {
        if (auto p = id in store)
            return *p;
        return null;
    }

    StorageObject findByKey(BucketId bucketId, string key)
    {
        foreach (ref e; store.byValue())
            if (e.bucketId == bucketId && e.key == key && e.status == ObjectStatus.active)
                return e;
        return null;
    }

    StorageObject[] findByBucket(BucketId bucketId)
    {
        return store.byValue()
            .filter!(e => e.bucketId == bucketId && e.status == ObjectStatus.active)
            .array;
    }

    StorageObject[] findByPrefix(BucketId bucketId, string prefix)
    {
        return store.byValue()
            .filter!(e => e.bucketId == bucketId && e.status == ObjectStatus.active
                && e.key.startsWith(prefix))
            .array;
    }

    void save(StorageObject entity) { store[entity.id] = entity; }
    void update(StorageObject entity) { store[entity.id] = entity; }
    void remove(ObjectId id) { store.remove(id); }
}
