module uim.platform.object_store.infrastructure.persistence.memory.object_version;

import uim.platform.object_store.domain.types;
import uim.platform.object_store.domain.entities.object_version;
import uim.platform.object_store.domain.ports.repositories.object_version;

import std.algorithm : filter;
import std.array : array;

class MemoryObjectVersionRepository : ObjectVersionRepository
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
