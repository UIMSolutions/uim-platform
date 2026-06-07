/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.mongodb.database_users;

import uim.platform.postgres;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter, any;
import std.array     : array;
import std.conv      : to;

// mixin(ShowModule!());

@safe:

class MongoDatabaseUserRepository : DatabaseUserRepository {
    private MongoCollection _collection;
    this(MongoCollection collection) { _collection = collection; }

    private DatabaseUser fromBson(Bson doc) {
        DatabaseUser e;
        e.id         = DatabaseUserId(doc["id"].get!string);
        e.tenantId   = TenantId(doc["tenantId"].get!string);
        e.instanceId = ServiceInstanceId(doc["instanceId"].get!string);
        e.username   = doc["username"].get!string;
        e.roles      = doc["roles"].get!string;
        e.status     = doc["status"].get!string.to!UserStatus;
        e.createdAt  = doc["createdAt"].get!long;
        e.createdBy  = UserId(doc["createdBy"].get!string);
        e.updatedBy  = UserId(doc["updatedBy"].get!string);
        return e;
    }

    private Bson toBson(DatabaseUser e) {
        return Bson([
            "id":         Bson(e.id.value),
            "tenantId":   Bson(e.tenantId.value),
            "instanceId": Bson(e.instanceId.value),
            "username":   Bson(e.username),
            "roles":      Bson(e.roles),
            "status":     Bson(e.status.to!string),
            "createdAt":  Bson(e.createdAt),
            "createdBy":  Bson(e.createdBy.value),
            "updatedBy":  Bson(e.updatedBy.value)
        ]);
    }

    bool isTenantEmpty(TenantId t)          { return findByTenant(t).length == 0; }
    void createTenant(TenantId t)            {}
    TenantId[] findAllTenants()              { return []; }
    bool existsByTenant(TenantId t)          { return !isTenantEmpty(t); }
    size_t countByTenant(TenantId t)         { return findByTenant(t).length; }
    DatabaseUser[] filterByTenant(DatabaseUser[] items, TenantId t) {
        return items.filter!(e => e.tenantId == t).array;
    }
    void removeByTenant(TenantId t) @trusted {
        _collection.remove(Bson(["tenantId": Bson(t.value)]));
    }
    DatabaseUser[] findByTenant(TenantId t, size_t offset = 0, size_t limit = 0) @trusted {
        DatabaseUser[] result;
        foreach (doc; _collection.find(Bson(["tenantId": Bson(t.value)]))) result ~= fromBson(doc);
        return result;
    }
    bool existsById(TenantId t, DatabaseUserId id) @trusted {
        return !_collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])).isNull;
    }
    DatabaseUser findById(TenantId t, DatabaseUserId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
        if (doc.isNull) return DatabaseUser.init;
        return fromBson(doc);
    }
    void removeById(TenantId t, DatabaseUserId id) @trusted {
        _collection.remove(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
    }
    bool existsAllById(TenantId t, DatabaseUserId[] ids) {
        import std.algorithm : all;
        return ids.all!(id => existsById(t, id));
    }
    DatabaseUser[] findAllById(TenantId t, DatabaseUserId[] ids) {
        DatabaseUser[] result;
        foreach (id; ids) { auto e = findById(t, id); if (e.id.value.length > 0) result ~= e; }
        return result;
    }
    void removeAllById(TenantId t, DatabaseUserId[] ids) { foreach (id; ids) removeById(t, id); }
    void save(DatabaseUser item) @trusted {
        auto q = Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]);
        _collection.update(q, Bson(["$set": toBson(item)]), UpdateFlags.upsert);
    }
    void saveAll(DatabaseUser[] items)     { foreach (i; items) save(i); }
    void update(DatabaseUser item)         { save(item); }
    void updateAll(DatabaseUser[] items)   { foreach (i; items) update(i); }
    bool exists(DatabaseUser item)         { return existsById(item.tenantId, item.id); }
    void remove(DatabaseUser item)         { removeById(item.tenantId, item.id); }
    void removeAll(DatabaseUser[] items)   { foreach (i; items) remove(i); }
    size_t countAll()                      { return findAll().length; }
    size_t indexOf(DatabaseUser item)      { return size_t.max; }
    DatabaseUser[] findAll(size_t offset = 0, size_t limit = 0) @trusted {
        DatabaseUser[] result;
        foreach (doc; _collection.find(Bson.emptyObject)) result ~= fromBson(doc);
        return result;
    }
    void removeAll() @trusted { _collection.remove(Bson.emptyObject); }

    override DatabaseUser[] findByInstance(TenantId t, ServiceInstanceId instanceId) {
        return findByTenant(t).filter!(e => e.instanceId == instanceId).array;
    }
    override DatabaseUser[] findByStatus(TenantId t, UserStatus status) {
        return findByTenant(t).filter!(e => e.status == status).array;
    }
    override bool usernameExists(TenantId t, ServiceInstanceId instanceId, string username) {
        return findByTenant(t).any!(e => e.instanceId == instanceId && e.username == username);
    }
}
