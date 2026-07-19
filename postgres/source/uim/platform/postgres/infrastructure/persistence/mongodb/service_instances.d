/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.mongodb.service_instances;

import uim.platform.postgres;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter, any;
import std.array     : array;
import std.conv      : to;
mixin(ShowModule!());

@safe:

class MongoServiceInstanceRepository : ServiceInstanceRepository {
    private MongoCollection _collection;
    this(MongoCollection collection) { _collection = collection; }

    private ServiceInstance fromBson(Bson doc) {
        ServiceInstance e;
        e.id            = ServiceInstanceId(doc["id"].get!string);
        e.tenantId      = TenantId(doc["tenantId"].get!string);
        e.name          = doc["name"].get!string;
        e.description   = doc["description"].get!string;
        e.planId        = ServicePlanId(doc["planId"].get!string);
        e.status        = doc["status"].get!string.to!InstanceStatus;
        e.hyperscaler   = doc["hyperscaler"].get!string.to!Hyperscaler;
        e.region        = doc["region"].get!string;
        e.engineVersion = doc["engineVersion"].get!string.to!PostgresVersion;
        e.memoryGb      = doc["memoryGb"].get!long;
        e.storageGb     = doc["storageGb"].get!long;
        e.host          = doc["host"].get!string;
        e.port          = cast(ushort) doc["port"].get!long;
        e.dbName        = doc["dbName"].get!string;
        e.sslEnabled    = doc["sslEnabled"].get!bool;
        e.multiAz       = doc["multiAz"].get!bool;
        e.provisionedAt = doc["provisionedAt"].get!long;
        e.updatedAt     = doc["updatedAt"].get!long;
        e.createdAt     = doc["createdAt"].get!long;
        e.createdBy     = UserId(doc["createdBy"].get!string);
        e.updatedBy     = UserId(doc["updatedBy"].get!string);
        return e;
    }

    private Bson toBson(ServiceInstance e) {
        return Bson([
            "id":            Bson(e.id.value),
            "tenantId":      Bson(e.tenantId.value),
            "name":          Bson(e.name),
            "description":   Bson(e.description),
            "planId":        Bson(e.planId.value),
            "status":        Bson(e.status.to!string),
            "hyperscaler":   Bson(e.hyperscaler.to!string),
            "region":        Bson(e.region),
            "engineVersion": Bson(e.engineVersion.to!string),
            "memoryGb":      Bson(e.memoryGb),
            "storageGb":     Bson(e.storageGb),
            "host":          Bson(e.host),
            "port":          Bson(cast(long) e.port),
            "dbName":        Bson(e.dbName),
            "sslEnabled":    Bson(e.sslEnabled),
            "multiAz":       Bson(e.multiAz),
            "provisionedAt": Bson(e.provisionedAt),
            "updatedAt":     Bson(e.updatedAt),
            "createdAt":     Bson(e.createdAt),
            "createdBy":     Bson(e.createdBy.value),
            "updatedBy":     Bson(e.updatedBy.value)
        ]);
    }

    bool isTenantEmpty(TenantId t)         { return findByTenant(t).length == 0; }
    void createTenant(TenantId t)           {}
    TenantId[] findAllTenants()             { return []; }
    bool existsByTenant(TenantId t)         { return !isTenantEmpty(t); }
    size_t countByTenant(TenantId t)        { return findByTenant(t).length; }
    ServiceInstance[] filterByTenant(ServiceInstance[] items, TenantId t) {
        return items.filter!(e => e.tenantId == t).array;
    }
    void removeByTenant(TenantId t) @trusted {
        _collection.remove(Bson(["tenantId": Bson(t.value)]));
    }
    ServiceInstance[] findByTenant(TenantId t, size_t offset = 0, size_t limit = 0) @trusted {
        ServiceInstance[] result;
        foreach (doc; _collection.find(Bson(["tenantId": Bson(t.value)]))) result ~= fromBson(doc);
        return result;
    }
    bool existsById(TenantId t, ServiceInstanceId id) @trusted {
        return !_collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])).isNull;
    }
    ServiceInstance findById(TenantId t, ServiceInstanceId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
        if (doc.isNull) return ServiceInstance.init;
        return fromBson(doc);
    }
    void removeById(TenantId t, ServiceInstanceId id) @trusted {
        _collection.remove(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
    }
    bool existsAllById(TenantId t, ServiceInstanceId[] ids) {
        import std.algorithm : all;
        return ids.all!(id => existsById(t, id));
    }
    ServiceInstance[] findAllById(TenantId t, ServiceInstanceId[] ids) {
        ServiceInstance[] result;
        foreach (id; ids) { auto e = findById(t, id); if (e.id.value.length > 0) result ~= e; }
        return result;
    }
    void removeAllById(TenantId t, ServiceInstanceId[] ids) { foreach (id; ids) removeById(t, id); }
    void save(ServiceInstance item) @trusted {
        auto q = Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]);
        _collection.update(q, Bson(["$set": toBson(item)]), UpdateFlags.upsert);
    }
    void saveAll(ServiceInstance[] items)     { foreach (i; items) save(i); }
    void update(ServiceInstance item)         { save(item); }
    void updateAll(ServiceInstance[] items)   { foreach (i; items) update(i); }
    bool exists(ServiceInstance item)         { return existsById(item.tenantId, item.id); }
    void remove(ServiceInstance item)         { removeById(item.tenantId, item.id); }
    void removeAll(ServiceInstance[] items)   { foreach (i; items) remove(i); }
    size_t countAll()                         { return findAll().length; }
    size_t indexOf(ServiceInstance item)      { return size_t.max; }
    ServiceInstance[] findAll(size_t offset = 0, size_t limit = 0) @trusted {
        ServiceInstance[] result;
        foreach (doc; _collection.find(Bson.emptyObject)) result ~= fromBson(doc);
        return result;
    }
    void removeAll() @trusted { _collection.remove(Bson.emptyObject); }

    override ServiceInstance[] findByStatus(TenantId t, InstanceStatus status) {
        return findByTenant(t).filter!(e => e.status == status).array;
    }
    override ServiceInstance[] findByPlan(TenantId t, ServicePlanId planId) {
        return findByTenant(t).filter!(e => e.planId == planId).array;
    }
    override ServiceInstance[] findByHyperscaler(TenantId t, Hyperscaler hs) {
        return findByTenant(t).filter!(e => e.hyperscaler == hs).array;
    }
    override bool nameExists(TenantId t, string name) {
        return findByTenant(t).any!(e => e.name == name);
    }
}
