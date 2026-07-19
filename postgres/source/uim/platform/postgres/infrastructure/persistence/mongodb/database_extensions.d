/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.mongodb.database_extensions;

import uim.platform.postgres;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter, any;
import std.array     : array;
import std.conv      : to;

mixin(ShowModule!());

@safe:

class MongoDatabaseExtensionRepository : DatabaseExtensionRepository {
    private MongoCollection _collection;
    this(MongoCollection collection) { _collection = collection; }

    private DatabaseExtension fromBson(Bson doc) {
        DatabaseExtension e;
        e.id               = DatabaseExtensionId(doc["id"].get!string);
        e.tenantId         = TenantId(doc["tenantId"].get!string);
        e.instanceId       = ServiceInstanceId(doc["instanceId"].get!string);
        e.extensionName    = doc["extensionName"].get!string;
        e.extensionVersion = doc["extensionVersion"].get!string;
        e.status           = doc["status"].get!string.to!ExtensionStatus;
        e.schema_          = doc["schema"].get!string;
        e.createdAt        = doc["createdAt"].get!long;
        e.createdBy        = UserId(doc["createdBy"].get!string);
        e.updatedBy        = UserId(doc["updatedBy"].get!string);
        return e;
    }

    private Bson toBson(DatabaseExtension e) {
        return Bson([
            "id":               Bson(e.id.value),
            "tenantId":         Bson(e.tenantId.value),
            "instanceId":       Bson(e.instanceId.value),
            "extensionName":    Bson(e.extensionName),
            "extensionVersion": Bson(e.extensionVersion),
            "status":           Bson(e.status.to!string),
            "schema":           Bson(e.schema_),
            "createdAt":        Bson(e.createdAt),
            "createdBy":        Bson(e.createdBy.value),
            "updatedBy":        Bson(e.updatedBy.value)
        ]);
    }

    bool isTenantEmpty(TenantId t)             { return findByTenant(t).length == 0; }
    void createTenant(TenantId t)               {}
    TenantId[] findAllTenants()                 { return []; }
    bool existsByTenant(TenantId t)             { return !isTenantEmpty(t); }
    size_t countByTenant(TenantId t)            { return findByTenant(t).length; }
    DatabaseExtension[] filterByTenant(DatabaseExtension[] items, TenantId t) {
        return items.filter!(e => e.tenantId == t).array;
    }
    void removeByTenant(TenantId t) @trusted {
        _collection.remove(Bson(["tenantId": Bson(t.value)]));
    }
    DatabaseExtension[] findByTenant(TenantId t, size_t offset = 0, size_t limit = 0) @trusted {
        DatabaseExtension[] result;
        foreach (doc; _collection.find(Bson(["tenantId": Bson(t.value)]))) result ~= fromBson(doc);
        return result;
    }
    bool existsById(TenantId t, DatabaseExtensionId id) @trusted {
        return !_collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])).isNull;
    }
    DatabaseExtension findById(TenantId t, DatabaseExtensionId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
        if (doc.isNull) return DatabaseExtension.init;
        return fromBson(doc);
    }
    void removeById(TenantId t, DatabaseExtensionId id) @trusted {
        _collection.remove(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
    }
    bool existsAllById(TenantId t, DatabaseExtensionId[] ids) {
        import std.algorithm : all;
        return ids.all!(id => existsById(t, id));
    }
    DatabaseExtension[] findAllById(TenantId t, DatabaseExtensionId[] ids) {
        DatabaseExtension[] result;
        foreach (id; ids) { auto e = findById(t, id); if (e.id.value.length > 0) result ~= e; }
        return result;
    }
    void removeAllById(TenantId t, DatabaseExtensionId[] ids) { foreach (id; ids) removeById(t, id); }
    void save(DatabaseExtension item) @trusted {
        auto q = Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]);
        _collection.update(q, Bson(["$set": toBson(item)]), UpdateFlags.upsert);
    }
    void saveAll(DatabaseExtension[] items)     { foreach (i; items) save(i); }
    void update(DatabaseExtension item)         { save(item); }
    void updateAll(DatabaseExtension[] items)   { foreach (i; items) update(i); }
    bool exists(DatabaseExtension item)         { return existsById(item.tenantId, item.id); }
    void remove(DatabaseExtension item)         { removeById(item.tenantId, item.id); }
    void removeAll(DatabaseExtension[] items)   { foreach (i; items) remove(i); }
    size_t countAll()                           { return findAll().length; }
    size_t indexOf(DatabaseExtension item)      { return size_t.max; }
    DatabaseExtension[] findAll(size_t offset = 0, size_t limit = 0) @trusted {
        DatabaseExtension[] result;
        foreach (doc; _collection.find(Bson.emptyObject)) result ~= fromBson(doc);
        return result;
    }
    void removeAll() @trusted { _collection.remove(Bson.emptyObject); }

    override DatabaseExtension[] findByInstance(TenantId t, ServiceInstanceId instanceId) {
        return findByTenant(t).filter!(e => e.instanceId == instanceId).array;
    }
    override DatabaseExtension[] findByStatus(TenantId t, ExtensionStatus status) {
        return findByTenant(t).filter!(e => e.status == status).array;
    }
    override bool extensionExists(TenantId t, ServiceInstanceId instanceId, string extensionName) {
        return findByTenant(t).any!(e => e.instanceId == instanceId && e.extensionName == extensionName);
    }
}
