/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.mongodb.backup_policies;

import uim.platform.redis;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter;
import std.array     : array;
import std.conv      : to;
mixin(ShowModule!());

@safe:

class MongoBackupPolicyRepository : BackupPolicyRepository {
    private MongoCollection _collection;
    this(MongoCollection collection) { _collection = collection; }

    private BackupPolicy fromBson(Bson doc) {
        BackupPolicy p;
        p.id          = BackupPolicyId(doc["id"].get!string);
        p.tenantId    = TenantId(doc["tenantId"].get!string);
        p.instanceId  = ServiceInstanceId(doc["instanceId"].get!string);
        p.enabled     = doc["enabled"].get!bool;
        p.intervalHours = doc["intervalHours"].get!long;
        p.retentionDays = doc["retentionDays"].get!long;
        p.lastBackupAt = doc["lastBackupAt"].get!long;
        p.nextBackupAt = doc["nextBackupAt"].get!long;
        p.status      = doc["status"].get!string.to!BackupStatus;
        p.backupLocation = doc["backupLocation"].get!string;
        p.lastBackupId = doc["lastBackupId"].get!string;
        p.lastError   = doc["lastError"].get!string;
        p.createdAt   = doc["createdAt"].get!long;
        return p;
    }
    private Bson toBson(BackupPolicy p) {
        return Bson(["id": Bson(p.id.value), "tenantId": Bson(p.tenantId.value),
            "instanceId": Bson(p.instanceId.value), "enabled": Bson(p.enabled),
            "intervalHours": Bson(p.intervalHours), "retentionDays": Bson(p.retentionDays),
            "lastBackupAt": Bson(p.lastBackupAt), "nextBackupAt": Bson(p.nextBackupAt),
            "status": Bson(p.status.to!string), "backupLocation": Bson(p.backupLocation),
            "lastBackupId": Bson(p.lastBackupId), "lastError": Bson(p.lastError), "createdAt": Bson(p.createdAt)]);
    }

    bool isTenantEmpty(TenantId t)                                { return findByTenant(t).length == 0; }
    void createTenant(TenantId t)                                 {}
    TenantId[] findAllTenants()                                   { return []; }
    bool existsByTenant(TenantId t)                               { return !isTenantEmpty(t); }
    size_t countByTenant(TenantId t)                              { return findByTenant(t).length; }
    BackupPolicy[] filterByTenant(BackupPolicy[] items, TenantId t) { return items.filter!(e => e.tenantId == t).array; }
    void removeByTenant(TenantId t) @trusted                     { _collection.remove(Bson(["tenantId": Bson(t.value)])); }
    BackupPolicy[] findByTenant(TenantId t, size_t o = 0, size_t l = 0) @trusted {
        BackupPolicy[] r; foreach (doc; _collection.find(Bson(["tenantId": Bson(t.value)]))) r ~= fromBson(doc); return r;
    }
    bool existsById(TenantId t, BackupPolicyId id) @trusted { return !_collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])).isNull; }
    BackupPolicy findById(TenantId t, BackupPolicyId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
        return doc.isNull ? BackupPolicy.init : fromBson(doc);
    }
    void removeById(TenantId t, BackupPolicyId id) @trusted { _collection.remove(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])); }
    bool existsAllById(TenantId t, BackupPolicyId[] ids) { import std.algorithm : all; return ids.all!(id => existsById(t, id)); }
    BackupPolicy[] findAllById(TenantId t, BackupPolicyId[] ids) { BackupPolicy[] r; foreach (id; ids) { auto e = findById(t, id); if (e.id.value.length > 0) r ~= e; } return r; }
    void removeAllById(TenantId t, BackupPolicyId[] ids) { foreach (id; ids) removeById(t, id); }
    void save(BackupPolicy item) @trusted { _collection.update(Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]), Bson(["$set": toBson(item)]), UpdateFlags.upsert); }
    void saveAll(BackupPolicy[] items) { foreach (i; items) save(i); }
    void update(BackupPolicy item) { save(item); }
    void updateAll(BackupPolicy[] items) { foreach (i; items) update(i); }
    bool exists(BackupPolicy item)  { return existsById(item.tenantId, item.id); }
    void remove(BackupPolicy item)  { removeById(item.tenantId, item.id); }
    void removeAll(BackupPolicy[] items) { foreach (i; items) remove(i); }
    size_t countAll()               { return findAll().length; }
    size_t indexOf(BackupPolicy i)  { return size_t.max; }
    BackupPolicy[] findAll(size_t o = 0, size_t l = 0) @trusted { BackupPolicy[] r; foreach (doc; _collection.find(Bson.emptyObject)) r ~= fromBson(doc); return r; }
    void removeAll() @trusted       { _collection.remove(Bson.emptyObject); }

    override BackupPolicy findByInstance(TenantId t, ServiceInstanceId iid) {
        auto r = findByTenant(t).filter!(e => e.instanceId == iid).array;
        return r.length > 0 ? r[0] : BackupPolicy.init;
    }
    override BackupPolicy[] findByStatus(TenantId t, BackupStatus status) {
        return findByTenant(t).filter!(e => e.status == status).array;
    }
}
