/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.mongodb.backup_policies;

import uim.platform.postgres;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter;
import std.array     : array;
import std.conv      : to;

// mixin(ShowModule!());

@safe:

class MongoBackupPolicyRepository : BackupPolicyRepository {
    private MongoCollection _collection;
    this(MongoCollection collection) { _collection = collection; }

    private BackupPolicy fromBson(Bson doc) {
        BackupPolicy e;
        e.id              = BackupPolicyId(doc["id"].get!string);
        e.tenantId        = TenantId(doc["tenantId"].get!string);
        e.instanceId      = ServiceInstanceId(doc["instanceId"].get!string);
        e.retentionPeriod = doc["retentionPeriod"].get!long;
        e.backupWindow    = doc["backupWindow"].get!string;
        e.lastBackupAt    = doc["lastBackupAt"].get!long;
        e.nextBackupAt    = doc["nextBackupAt"].get!long;
        e.status          = doc["status"].get!string.to!BackupStatus;
        e.backupLocation  = doc["backupLocation"].get!string;
        e.lastError       = doc["lastError"].get!string;
        e.createdAt       = doc["createdAt"].get!long;
        e.createdBy       = UserId(doc["createdBy"].get!string);
        e.updatedBy       = UserId(doc["updatedBy"].get!string);
        return e;
    }

    private Bson toBson(BackupPolicy e) {
        return Bson([
            "id":              Bson(e.id.value),
            "tenantId":        Bson(e.tenantId.value),
            "instanceId":      Bson(e.instanceId.value),
            "retentionPeriod": Bson(e.retentionPeriod),
            "backupWindow":    Bson(e.backupWindow),
            "lastBackupAt":    Bson(e.lastBackupAt),
            "nextBackupAt":    Bson(e.nextBackupAt),
            "status":          Bson(e.status.to!string),
            "backupLocation":  Bson(e.backupLocation),
            "lastError":       Bson(e.lastError),
            "createdAt":       Bson(e.createdAt),
            "createdBy":       Bson(e.createdBy.value),
            "updatedBy":       Bson(e.updatedBy.value)
        ]);
    }

    bool isTenantEmpty(TenantId t)          { return findByTenant(t).length == 0; }
    void createTenant(TenantId t)            {}
    TenantId[] findAllTenants()              { return []; }
    bool existsByTenant(TenantId t)          { return !isTenantEmpty(t); }
    size_t countByTenant(TenantId t)         { return findByTenant(t).length; }
    BackupPolicy[] filterByTenant(BackupPolicy[] items, TenantId t) {
        return items.filter!(e => e.tenantId == t).array;
    }
    void removeByTenant(TenantId t) @trusted {
        _collection.remove(Bson(["tenantId": Bson(t.value)]));
    }
    BackupPolicy[] findByTenant(TenantId t, size_t offset = 0, size_t limit = 0) @trusted {
        BackupPolicy[] result;
        foreach (doc; _collection.find(Bson(["tenantId": Bson(t.value)]))) result ~= fromBson(doc);
        return result;
    }
    bool existsById(TenantId t, BackupPolicyId id) @trusted {
        return !_collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])).isNull;
    }
    BackupPolicy findById(TenantId t, BackupPolicyId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
        if (doc.isNull) return BackupPolicy.init;
        return fromBson(doc);
    }
    void removeById(TenantId t, BackupPolicyId id) @trusted {
        _collection.remove(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
    }
    bool existsAllById(TenantId t, BackupPolicyId[] ids) {
        import std.algorithm : all;
        return ids.all!(id => existsById(t, id));
    }
    BackupPolicy[] findAllById(TenantId t, BackupPolicyId[] ids) {
        BackupPolicy[] result;
        foreach (id; ids) { auto e = findById(t, id); if (e.id.value.length > 0) result ~= e; }
        return result;
    }
    void removeAllById(TenantId t, BackupPolicyId[] ids) { foreach (id; ids) removeById(t, id); }
    void save(BackupPolicy item) @trusted {
        auto q = Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]);
        _collection.update(q, Bson(["$set": toBson(item)]), UpdateFlags.upsert);
    }
    void saveAll(BackupPolicy[] items)     { foreach (i; items) save(i); }
    void update(BackupPolicy item)         { save(item); }
    void updateAll(BackupPolicy[] items)   { foreach (i; items) update(i); }
    bool exists(BackupPolicy item)         { return existsById(item.tenantId, item.id); }
    void remove(BackupPolicy item)         { removeById(item.tenantId, item.id); }
    void removeAll(BackupPolicy[] items)   { foreach (i; items) remove(i); }
    size_t countAll()                      { return findAll().length; }
    size_t indexOf(BackupPolicy item)      { return size_t.max; }
    BackupPolicy[] findAll(size_t offset = 0, size_t limit = 0) @trusted {
        BackupPolicy[] result;
        foreach (doc; _collection.find(Bson.emptyObject)) result ~= fromBson(doc);
        return result;
    }
    void removeAll() @trusted { _collection.remove(Bson.emptyObject); }

    override BackupPolicy findByInstance(TenantId t, ServiceInstanceId instanceId) {
        auto r = findByTenant(t).filter!(e => e.instanceId == instanceId).array;
        return r.length > 0 ? r[0] : BackupPolicy.init;
    }
    override BackupPolicy[] findByStatus(TenantId t, BackupStatus status) {
        return findByTenant(t).filter!(e => e.status == status).array;
    }
}
