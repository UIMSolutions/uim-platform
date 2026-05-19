/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.mongodb.access_controls;

import uim.platform.redis;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter, any;
import std.array     : array;
import std.conv      : to;

mixin(ShowModule!());

@safe:

class MongoAccessControlRepository : AccessControlRepository {
    private MongoCollection _collection;
    this(MongoCollection collection) { _collection = collection; }

    private AccessControl fromBson(Bson doc) {
        AccessControl a;
        a.id          = AccessControlId(doc["id"].get!string);
        a.tenantId    = TenantId(doc["tenantId"].get!string);
        a.instanceId  = ServiceInstanceId(doc["instanceId"].get!string);
        a.cidr        = doc["cidr"].get!string;
        a.description = doc["description"].get!string;
        a.status      = doc["status"].get!string.to!AccessControlStatus;
        a.createdAt   = doc["createdAt"].get!long;
        return a;
    }
    private Bson toBson(AccessControl a) {
        return Bson(["id": Bson(a.id.value), "tenantId": Bson(a.tenantId.value),
            "instanceId": Bson(a.instanceId.value), "cidr": Bson(a.cidr),
            "description": Bson(a.description), "status": Bson(a.status.to!string), "createdAt": Bson(a.createdAt)]);
    }

    bool isTenantEmpty(TenantId t)                                  { return findByTenant(t).length == 0; }
    void createTenant(TenantId t)                                   {}
    TenantId[] findAllTenants()                                     { return []; }
    bool existsByTenant(TenantId t)                                 { return !isTenantEmpty(t); }
    size_t countByTenant(TenantId t)                                { return findByTenant(t).length; }
    AccessControl[] filterByTenant(AccessControl[] items, TenantId t) { return items.filter!(e => e.tenantId == t).array; }
    void removeByTenant(TenantId t) @trusted                       { _collection.remove(Bson(["tenantId": Bson(t.value)])); }
    AccessControl[] findByTenant(TenantId t, size_t o = 0, size_t l = 0) @trusted {
        AccessControl[] r; foreach (doc; _collection.find(Bson(["tenantId": Bson(t.value)]))) r ~= fromBson(doc); return r;
    }
    bool existsById(TenantId t, AccessControlId id) @trusted { return !_collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])).isNull; }
    AccessControl findById(TenantId t, AccessControlId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
        return doc.isNull ? AccessControl.init : fromBson(doc);
    }
    void removeById(TenantId t, AccessControlId id) @trusted { _collection.remove(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])); }
    bool existsAllById(TenantId t, AccessControlId[] ids) { import std.algorithm : all; return ids.all!(id => existsById(t, id)); }
    AccessControl[] findAllById(TenantId t, AccessControlId[] ids) { AccessControl[] r; foreach (id; ids) { auto e = findById(t, id); if (e.id.value.length > 0) r ~= e; } return r; }
    void removeAllById(TenantId t, AccessControlId[] ids) { foreach (id; ids) removeById(t, id); }
    void save(AccessControl item) @trusted { _collection.update(Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]), Bson(["$set": toBson(item)]), UpdateFlags.upsert); }
    void saveAll(AccessControl[] items) { foreach (i; items) save(i); }
    void update(AccessControl item) { save(item); }
    void updateAll(AccessControl[] items) { foreach (i; items) update(i); }
    bool exists(AccessControl item)  { return existsById(item.tenantId, item.id); }
    void remove(AccessControl item)  { removeById(item.tenantId, item.id); }
    void removeAll(AccessControl[] items) { foreach (i; items) remove(i); }
    size_t countAll()                { return findAll().length; }
    size_t indexOf(AccessControl i)  { return size_t.max; }
    AccessControl[] findAll(size_t o = 0, size_t l = 0) @trusted { AccessControl[] r; foreach (doc; _collection.find(Bson.emptyObject)) r ~= fromBson(doc); return r; }
    void removeAll() @trusted        { _collection.remove(Bson.emptyObject); }

    override AccessControl[] findByInstance(TenantId t, ServiceInstanceId iid)   { return findByTenant(t).filter!(e => e.instanceId == iid).array; }
    override AccessControl[] findByStatus(TenantId t, AccessControlStatus status) { return findByTenant(t).filter!(e => e.status == status).array; }
    override bool cidrExists(TenantId t, ServiceInstanceId iid, string cidr)      { return findByTenant(t).any!(e => e.instanceId == iid && e.cidr == cidr); }
}
