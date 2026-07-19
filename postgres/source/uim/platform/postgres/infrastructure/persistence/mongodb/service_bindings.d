/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.mongodb.service_bindings;

import uim.platform.postgres;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter;
import std.array     : array;
import std.conv      : to;
mixin(ShowModule!());

@safe:

class MongoServiceBindingRepository : ServiceBindingRepository {
    private MongoCollection _collection;
    this(MongoCollection collection) { _collection = collection; }

    private ServiceBinding fromBson(Bson doc) {
        ServiceBinding e;
        e.id          = ServiceBindingId(doc["id"].get!string);
        e.tenantId    = TenantId(doc["tenantId"].get!string);
        e.instanceId  = ServiceInstanceId(doc["instanceId"].get!string);
        e.appId       = doc["appId"].get!string;
        e.name        = doc["name"].get!string;
        e.status      = doc["status"].get!string.to!BindingStatus;
        e.bindingHost = doc["bindingHost"].get!string;
        e.bindingPort = cast(ushort) doc["bindingPort"].get!long;
        e.username    = doc["username"].get!string;
        e.database    = doc["database"].get!string;
        e.sslMode     = doc["sslMode"].get!string.to!SslMode;
        e.expiresAt   = doc["expiresAt"].get!long;
        e.createdAt   = doc["createdAt"].get!long;
        e.createdBy   = UserId(doc["createdBy"].get!string);
        e.updatedBy   = UserId(doc["updatedBy"].get!string);
        return e;
    }

    private Bson toBson(ServiceBinding e) {
        return Bson([
            "id":          Bson(e.id.value),
            "tenantId":    Bson(e.tenantId.value),
            "instanceId":  Bson(e.instanceId.value),
            "appId":       Bson(e.appId),
            "name":        Bson(e.name),
            "status":      Bson(e.status.to!string),
            "bindingHost": Bson(e.bindingHost),
            "bindingPort": Bson(cast(long) e.bindingPort),
            "username":    Bson(e.username),
            "database":    Bson(e.database),
            "sslMode":     Bson(e.sslMode.to!string),
            "expiresAt":   Bson(e.expiresAt),
            "createdAt":   Bson(e.createdAt),
            "createdBy":   Bson(e.createdBy.value),
            "updatedBy":   Bson(e.updatedBy.value)
        ]);
    }

    bool isTenantEmpty(TenantId t)         { return findByTenant(t).length == 0; }
    void createTenant(TenantId t)           {}
    TenantId[] findAllTenants()             { return []; }
    bool existsByTenant(TenantId t)         { return !isTenantEmpty(t); }
    size_t countByTenant(TenantId t)        { return findByTenant(t).length; }
    ServiceBinding[] filterByTenant(ServiceBinding[] items, TenantId t) {
        return items.filter!(e => e.tenantId == t).array;
    }
    void removeByTenant(TenantId t) @trusted {
        _collection.remove(Bson(["tenantId": Bson(t.value)]));
    }
    ServiceBinding[] findByTenant(TenantId t, size_t offset = 0, size_t limit = 0) @trusted {
        ServiceBinding[] result;
        foreach (doc; _collection.find(Bson(["tenantId": Bson(t.value)]))) result ~= fromBson(doc);
        return result;
    }
    bool existsById(TenantId t, ServiceBindingId id) @trusted {
        return !_collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])).isNull;
    }
    ServiceBinding findById(TenantId t, ServiceBindingId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
        if (doc.isNull) return ServiceBinding.init;
        return fromBson(doc);
    }
    void removeById(TenantId t, ServiceBindingId id) @trusted {
        _collection.remove(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
    }
    bool existsAllById(TenantId t, ServiceBindingId[] ids) {
        import std.algorithm : all;
        return ids.all!(id => existsById(t, id));
    }
    ServiceBinding[] findAllById(TenantId t, ServiceBindingId[] ids) {
        ServiceBinding[] result;
        foreach (id; ids) { auto e = findById(t, id); if (e.id.value.length > 0) result ~= e; }
        return result;
    }
    void removeAllById(TenantId t, ServiceBindingId[] ids) { foreach (id; ids) removeById(t, id); }
    void save(ServiceBinding item) @trusted {
        auto q = Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]);
        _collection.update(q, Bson(["$set": toBson(item)]), UpdateFlags.upsert);
    }
    void saveAll(ServiceBinding[] items)     { foreach (i; items) save(i); }
    void update(ServiceBinding item)         { save(item); }
    void updateAll(ServiceBinding[] items)   { foreach (i; items) update(i); }
    bool exists(ServiceBinding item)         { return existsById(item.tenantId, item.id); }
    void remove(ServiceBinding item)         { removeById(item.tenantId, item.id); }
    void removeAll(ServiceBinding[] items)   { foreach (i; items) remove(i); }
    size_t countAll()                        { return findAll().length; }
    size_t indexOf(ServiceBinding item)      { return size_t.max; }
    ServiceBinding[] findAll(size_t offset = 0, size_t limit = 0) @trusted {
        ServiceBinding[] result;
        foreach (doc; _collection.find(Bson.emptyObject)) result ~= fromBson(doc);
        return result;
    }
    void removeAll() @trusted { _collection.remove(Bson.emptyObject); }

    override ServiceBinding[] findByInstance(TenantId t, ServiceInstanceId iid) {
        return findByTenant(t).filter!(e => e.instanceId == iid).array;
    }
    override ServiceBinding[] findByStatus(TenantId t, BindingStatus status) {
        return findByTenant(t).filter!(e => e.status == status).array;
    }
    override ServiceBinding findByInstanceAndApp(TenantId t, ServiceInstanceId iid, string appId) {
        auto r = findByTenant(t).filter!(e => e.instanceId == iid && e.appId == appId).array;
        return r.length > 0 ? r[0] : ServiceBinding.init;
    }
}
