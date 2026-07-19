/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.mongodb.configurations;

import uim.platform.redis;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter;
import std.array     : array;
import std.conv      : to;
mixin(ShowModule!());

@safe:

class MongoConfigurationRepository : ConfigurationRepository {
    private MongoCollection _collection;
    this(MongoCollection collection) { _collection = collection; }

    private Configuration fromBson(Bson doc) {
        Configuration c;
        c.id              = ConfigurationId(doc["id"].get!string);
        c.tenantId        = TenantId(doc["tenantId"].get!string);
        c.instanceId      = ServiceInstanceId(doc["instanceId"].get!string);
        c.maxMemoryPolicy = doc["maxMemoryPolicy"].get!string.to!MaxMemoryPolicy;
        c.timeout         = doc["timeout"].get!long;
        c.maxConnections  = doc["maxConnections"].get!long;
        c.tlsEnabled      = doc["tlsEnabled"].get!bool;
        c.persistenceMode = doc["persistenceMode"].get!string.to!PersistenceMode;
        c.maxMemoryMb     = doc["maxMemoryMb"].get!long;
        c.notifyKeyspaceEvents = doc["notifyKeyspaceEvents"].get!bool;
        c.activeVersion   = doc["activeVersion"].get!string;
        c.createdAt       = doc["createdAt"].get!long;
        return c;
    }
    private Bson toBson(Configuration c) {
        return Bson(["id": Bson(c.id.value), "tenantId": Bson(c.tenantId.value),
            "instanceId": Bson(c.instanceId.value), "maxMemoryPolicy": Bson(c.maxMemoryPolicy.to!string),
            "timeout": Bson(c.timeout), "maxConnections": Bson(c.maxConnections),
            "tlsEnabled": Bson(c.tlsEnabled), "persistenceMode": Bson(c.persistenceMode.to!string),
            "maxMemoryMb": Bson(c.maxMemoryMb), "notifyKeyspaceEvents": Bson(c.notifyKeyspaceEvents),
            "activeVersion": Bson(c.activeVersion), "createdAt": Bson(c.createdAt)]);
    }

    bool isTenantEmpty(TenantId t)                              { return findByTenant(t).length == 0; }
    void createTenant(TenantId t)                               {}
    TenantId[] findAllTenants()                                 { return []; }
    bool existsByTenant(TenantId t)                             { return !isTenantEmpty(t); }
    size_t countByTenant(TenantId t)                            { return findByTenant(t).length; }
    Configuration[] filterByTenant(Configuration[] items, TenantId t) { return items.filter!(e => e.tenantId == t).array; }
    void removeByTenant(TenantId t) @trusted                   { _collection.remove(Bson(["tenantId": Bson(t.value)])); }
    Configuration[] findByTenant(TenantId t, size_t o = 0, size_t l = 0) @trusted {
        Configuration[] r; foreach (doc; _collection.find(Bson(["tenantId": Bson(t.value)]))) r ~= fromBson(doc); return r;
    }
    bool existsById(TenantId t, ConfigurationId id) @trusted { return !_collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])).isNull; }
    Configuration findById(TenantId t, ConfigurationId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
        return doc.isNull ? Configuration.init : fromBson(doc);
    }
    void removeById(TenantId t, ConfigurationId id) @trusted { _collection.remove(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])); }
    bool existsAllById(TenantId t, ConfigurationId[] ids) { import std.algorithm : all; return ids.all!(id => existsById(t, id)); }
    Configuration[] findAllById(TenantId t, ConfigurationId[] ids) { Configuration[] r; foreach (id; ids) { auto e = findById(t, id); if (e.id.value.length > 0) r ~= e; } return r; }
    void removeAllById(TenantId t, ConfigurationId[] ids) { foreach (id; ids) removeById(t, id); }
    void save(Configuration item) @trusted { _collection.update(Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]), Bson(["$set": toBson(item)]), UpdateFlags.upsert); }
    void saveAll(Configuration[] items) { foreach (i; items) save(i); }
    void update(Configuration item) { save(item); }
    void updateAll(Configuration[] items) { foreach (i; items) update(i); }
    bool exists(Configuration item)  { return existsById(item.tenantId, item.id); }
    void remove(Configuration item)  { removeById(item.tenantId, item.id); }
    void removeAll(Configuration[] items) { foreach (i; items) remove(i); }
    size_t countAll()                { return findAll().length; }
    size_t indexOf(Configuration i)  { return size_t.max; }
    Configuration[] findAll(size_t o = 0, size_t l = 0) @trusted { Configuration[] r; foreach (doc; _collection.find(Bson.emptyObject)) r ~= fromBson(doc); return r; }
    void removeAll() @trusted        { _collection.remove(Bson.emptyObject); }

    override Configuration findByInstance(TenantId t, ServiceInstanceId instanceId) {
        auto r = findByTenant(t).filter!(e => e.instanceId == instanceId).array;
        return r.length > 0 ? r[0] : Configuration.init;
    }
}
