/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.mongodb.service_bindings;

import uim.platform.redis;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter, any;
import std.array     : array;
import std.conv      : to;

mixin(ShowModule!());

@safe:

class MongoServiceBindingRepository : ServiceBindingRepository {
    private MongoCollection _collection;
    this(MongoCollection collection) { _collection = collection; }

    private ServiceBinding fromBson(Bson doc) {
        ServiceBinding b;
        b.id          = ServiceBindingId(doc["id"].get!string);
        b.tenantId    = TenantId(doc["tenantId"].get!string);
        b.instanceId  = ServiceInstanceId(doc["instanceId"].get!string);
        b.appId       = doc["appId"].get!string;
        b.name        = doc["name"].get!string;
        b.status      = doc["status"].get!string.to!BindingStatus;
        b.bindingHost = doc["bindingHost"].get!string;
        b.bindingPort = cast(ushort) doc["bindingPort"].get!long;
        b.expiresAt   = doc["expiresAt"].get!long;
        b.createdAt   = doc["createdAt"].get!long;
        return b;
    }

    private Bson toBson(ServiceBinding b) {
        return Bson([
            "id": Bson(b.id.value), "tenantId": Bson(b.tenantId.value),
            "instanceId": Bson(b.instanceId.value), "appId": Bson(b.appId), "name": Bson(b.name),
            "status": Bson(b.status.to!string), "bindingHost": Bson(b.bindingHost),
            "bindingPort": Bson(cast(long) b.bindingPort), "expiresAt": Bson(b.expiresAt),
            "createdAt": Bson(b.createdAt)
        ]);
    }

    // ITenantRepository boilerplate
    bool isTenantEmpty(TenantId t)                            { return findByTenant(t).length == 0; }
    void createTenant(TenantId t)                             {}
    TenantId[] findAllTenants()                               { return []; }
    bool existsByTenant(TenantId t)                           { return !isTenantEmpty(t); }
    size_t countByTenant(TenantId t)                          { return findByTenant(t).length; }
    ServiceBinding[] filterByTenant(ServiceBinding[] items, TenantId t) { return items.filter!(e => e.tenantId == t).array; }
    void removeByTenant(TenantId t) @trusted                 { _collection.remove(Bson(["tenantId": Bson(t.value)])); }
    ServiceBinding[] findByTenant(TenantId t, size_t o = 0, size_t l = 0) @trusted {
        ServiceBinding[] r;
        foreach (doc; _collection.find(Bson(["tenantId": Bson(t.value)]))) r ~= fromBson(doc);
        return r;
    }
    bool existsById(TenantId t, ServiceBindingId id) @trusted { return !_collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])).isNull; }
    ServiceBinding findById(TenantId t, ServiceBindingId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
        return doc.isNull ? ServiceBinding.init : fromBson(doc);
    }
    void removeById(TenantId t, ServiceBindingId id) @trusted { _collection.remove(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])); }
    bool existsAllById(TenantId t, ServiceBindingId[] ids)    { import std.algorithm : all; return ids.all!(id => existsById(t, id)); }
    ServiceBinding[] findAllById(TenantId t, ServiceBindingId[] ids) { ServiceBinding[] r; foreach (id; ids) { auto e = findById(t, id); if (e.id.value.length > 0) r ~= e; } return r; }
    void removeAllById(TenantId t, ServiceBindingId[] ids)    { foreach (id; ids) removeById(t, id); }
    void save(ServiceBinding item) @trusted                   { _collection.update(Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]), Bson(["$set": toBson(item)]), UpdateFlags.upsert); }
    void saveAll(ServiceBinding[] items)                      { foreach (i; items) save(i); }
    void update(ServiceBinding item)                          { save(item); }
    void updateAll(ServiceBinding[] items)                    { foreach (i; items) update(i); }
    bool exists(ServiceBinding item)                          { return existsById(item.tenantId, item.id); }
    void remove(ServiceBinding item)                          { removeById(item.tenantId, item.id); }
    void removeAll(ServiceBinding[] items)                    { foreach (i; items) remove(i); }
    size_t countAll()                                         { return findAll().length; }
    size_t indexOf(ServiceBinding item)                       { return size_t.max; }
    ServiceBinding[] findAll(size_t o = 0, size_t l = 0) @trusted { ServiceBinding[] r; foreach (doc; _collection.find(Bson.emptyObject)) r ~= fromBson(doc); return r; }
    void removeAll() @trusted                                 { _collection.remove(Bson.emptyObject); }

    // ServiceBindingRepository
    override ServiceBinding[] findByInstance(TenantId t, ServiceInstanceId instanceId)    { return findByTenant(t).filter!(e => e.instanceId == instanceId).array; }
    override ServiceBinding[] findByStatus(TenantId t, BindingStatus status)              { return findByTenant(t).filter!(e => e.status == status).array; }
    override ServiceBinding findByInstanceAndApp(TenantId t, ServiceInstanceId iid, string appId) {
        auto r = findByTenant(t).filter!(e => e.instanceId == iid && e.appId == appId).array;
        return r.length > 0 ? r[0] : ServiceBinding.init;
    }
}
