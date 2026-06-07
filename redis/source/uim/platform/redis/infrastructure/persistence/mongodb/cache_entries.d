/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.mongodb.cache_entries;

import uim.platform.redis;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter, any;
import std.array     : array;
import std.conv      : to;

// mixin(ShowModule!());

@safe:

class MongoCacheEntryRepository : CacheEntryRepository {
    private MongoCollection _collection;
    this(MongoCollection collection) { _collection = collection; }

    private CacheEntry fromBson(Bson doc) {
        CacheEntry e;
        e.id          = CacheEntryId(doc["id"].get!string);
        e.tenantId    = TenantId(doc["tenantId"].get!string);
        e.instanceId  = ServiceInstanceId(doc["instanceId"].get!string);
        e.key         = doc["key"].get!string;
        e.value       = doc["value"].get!string;
        e.entryType   = doc["entryType"].get!string.to!CacheEntryType;
        e.ttl         = doc["ttl"].get!long;
        e.sizeBytes   = doc["sizeBytes"].get!long;
        e.accessCount = doc["accessCount"].get!long;
        e.lastAccessedAt = doc["lastAccessedAt"].get!long;
        e.createdAt   = doc["createdAt"].get!long;
        return e;
    }
    private Bson toBson(CacheEntry e) {
        return Bson(["id": Bson(e.id.value), "tenantId": Bson(e.tenantId.value),
            "instanceId": Bson(e.instanceId.value), "key": Bson(e.key), "value": Bson(e.value),
            "entryType": Bson(e.entryType.to!string), "ttl": Bson(e.ttl), "sizeBytes": Bson(e.sizeBytes),
            "accessCount": Bson(e.accessCount), "lastAccessedAt": Bson(e.lastAccessedAt), "createdAt": Bson(e.createdAt)]);
    }

    bool isTenantEmpty(TenantId t)                           { return findByTenant(t).length == 0; }
    void createTenant(TenantId t)                            {}
    TenantId[] findAllTenants()                              { return []; }
    bool existsByTenant(TenantId t)                          { return !isTenantEmpty(t); }
    size_t countByTenant(TenantId t)                         { return findByTenant(t).length; }
    CacheEntry[] filterByTenant(CacheEntry[] items, TenantId t) { return items.filter!(e => e.tenantId == t).array; }
    void removeByTenant(TenantId t) @trusted                { _collection.remove(Bson(["tenantId": Bson(t.value)])); }
    CacheEntry[] findByTenant(TenantId t, size_t o = 0, size_t l = 0) @trusted {
        CacheEntry[] r; foreach (doc; _collection.find(Bson(["tenantId": Bson(t.value)]))) r ~= fromBson(doc); return r;
    }
    bool existsById(TenantId t, CacheEntryId id) @trusted { return !_collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])).isNull; }
    CacheEntry findById(TenantId t, CacheEntryId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
        return doc.isNull ? CacheEntry.init : fromBson(doc);
    }
    void removeById(TenantId t, CacheEntryId id) @trusted { _collection.remove(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])); }
    bool existsAllById(TenantId t, CacheEntryId[] ids) { import std.algorithm : all; return ids.all!(id => existsById(t, id)); }
    CacheEntry[] findAllById(TenantId t, CacheEntryId[] ids) { CacheEntry[] r; foreach (id; ids) { auto e = findById(t, id); if (e.id.value.length > 0) r ~= e; } return r; }
    void removeAllById(TenantId t, CacheEntryId[] ids) { foreach (id; ids) removeById(t, id); }
    void save(CacheEntry item) @trusted { _collection.update(Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]), Bson(["$set": toBson(item)]), UpdateFlags.upsert); }
    void saveAll(CacheEntry[] items) { foreach (i; items) save(i); }
    void update(CacheEntry item) { save(item); }
    void updateAll(CacheEntry[] items) { foreach (i; items) update(i); }
    bool exists(CacheEntry item)  { return existsById(item.tenantId, item.id); }
    void remove(CacheEntry item)  { removeById(item.tenantId, item.id); }
    void removeAll(CacheEntry[] items) { foreach (i; items) remove(i); }
    size_t countAll()             { return findAll().length; }
    size_t indexOf(CacheEntry i)  { return size_t.max; }
    CacheEntry[] findAll(size_t o = 0, size_t l = 0) @trusted { CacheEntry[] r; foreach (doc; _collection.find(Bson.emptyObject)) r ~= fromBson(doc); return r; }
    void removeAll() @trusted     { _collection.remove(Bson.emptyObject); }

    override CacheEntry[] findByInstance(TenantId t, ServiceInstanceId iid) { return findByTenant(t).filter!(e => e.instanceId == iid).array; }
    override CacheEntry findByKey(TenantId t, ServiceInstanceId iid, string key) {
        auto r = findByTenant(t).filter!(e => e.instanceId == iid && e.key == key).array;
        return r.length > 0 ? r[0] : CacheEntry.init;
    }
    override CacheEntry[] findByType(TenantId t, ServiceInstanceId iid, CacheEntryType et) { return findByTenant(t).filter!(e => e.instanceId == iid && e.entryType == et).array; }
    override bool keyExists(TenantId t, ServiceInstanceId iid, string key) { return findByTenant(t).any!(e => e.instanceId == iid && e.key == key); }
    override long countByInstance(TenantId t, ServiceInstanceId iid) { return cast(long) findByTenant(t).filter!(e => e.instanceId == iid).array.length; }
}
