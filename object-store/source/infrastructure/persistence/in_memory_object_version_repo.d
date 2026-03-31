module infrastructure.persistence.in_memory_object_version_repo;

import domain.types;
import domain.entities.object_version;
import domain.ports.object_version_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryObjectVersionRepository : ObjectVersionRepository
{
    private ObjectVersion[ObjectVersionId] store;

    ObjectVersion findById(ObjectVersionId id)
    {
        if (auto p = id in store)
            return *p;
        return null;
    }

    ObjectVersion[] findByObject(ObjectId objectId)
    {
        return store.byValue().filter!(e => e.objectId == objectId).array;
    }

    ObjectVersion findLatest(ObjectId objectId)
    {
        foreach (ref e; store.byValue())
            if (e.objectId == objectId && e.isLatest)
                return e;
        return null;
    }

    void save(ObjectVersion entity) { store[entity.id] = entity; }

    void remove(ObjectVersionId id) { store.remove(id); }

    void removeByObject(ObjectId objectId)
    {
        ObjectVersionId[] toRemove;
        foreach (ref kv; store.byKeyValue())
            if (kv.value.objectId == objectId)
                toRemove ~= kv.key;
        foreach (id; toRemove)
            store.remove(id);
    }
}
