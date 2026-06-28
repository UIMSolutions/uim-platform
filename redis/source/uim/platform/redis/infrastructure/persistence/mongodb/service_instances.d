/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.mongodb.service_instances;

import uim.platform.redis;
import vibe.db.mongo.mongo : MongoClient, MongoCollection, connectMongoDB;
import std.algorithm : filter, any;
import std.array     : array;
import std.conv      : to;

// mixin(ShowModule!());

@safe:

/// MongoDB repository for ServiceInstance.
/// Collection name: service_instances (per database — one DB per tenant).
class MongoServiceInstanceRepository : ServiceInstanceRepository {
    private MongoCollection _collection;

    this(MongoCollection collection) {
        _collection = collection;
    }

    private ServiceInstance fromBson(Bson doc) {
        ServiceInstance inst;
        inst.id          = ServiceInstanceId(doc["id"].get!string);
        inst.tenantId    = TenantId(doc["tenantId"].get!string);
        inst.name        = doc["name"].get!string;
        inst.description = doc["description"].get!string;
        inst.planId      = ServicePlanId(doc["planId"].get!string);
        inst.status      = doc["status"].get!string.to!InstanceStatus;
        inst.hyperscaler = doc["hyperscaler"].get!string.to!Hyperscaler;
        inst.region      = doc["region"].get!string;
        inst.redisVersion = doc["redisVersion"].get!string.to!RedisVersion;
        inst.memoryMb    = doc["memoryMb"].get!long;
        inst.maxConnections = doc["maxConnections"].get!long;
        inst.host        = doc["host"].get!string;
        inst.port        = cast(ushort) doc["port"].get!long;
        inst.tlsEnabled  = doc["tlsEnabled"].get!bool;
        inst.haEnabled   = doc["haEnabled"].get!bool;
        inst.persistenceMode = doc["persistenceMode"].get!string.to!PersistenceMode;
        inst.provisionedAt = doc["provisionedAt"].get!long;
        inst.updatedAt   = doc["updatedAt"].get!long;
        inst.createdAt   = doc["createdAt"].get!long;
        return inst;
    }

    private Bson toBson(ServiceInstance inst) {
        return Bson([
            "id":          Bson(inst.id.value),
            "tenantId":    Bson(inst.tenantId.value),
            "name":        Bson(inst.name),
            "description": Bson(inst.description),
            "planId":      Bson(inst.planId.value),
            "status":      Bson(inst.status.to!string),
            "hyperscaler": Bson(inst.hyperscaler.to!string),
            "region":      Bson(inst.region),
            "redisVersion": Bson(inst.redisVersion.to!string),
            "memoryMb":    Bson(inst.memoryMb),
            "maxConnections": Bson(inst.maxConnections),
            "host":        Bson(inst.host),
            "port":        Bson(cast(long) inst.port),
            "tlsEnabled":  Bson(inst.tlsEnabled),
            "haEnabled":   Bson(inst.haEnabled),
            "persistenceMode": Bson(inst.persistenceMode.to!string),
            "provisionedAt": Bson(inst.provisionedAt),
            "updatedAt":   Bson(inst.updatedAt),
            "createdAt":   Bson(inst.createdAt)
        ]);
    }

    // --- ITenantRepository stub implementations ---
    bool isTenantEmpty(TenantId tenantId)      { return find(tenantId).length == 0; }
    void createTenant(TenantId tenantId)        {}
    TenantId[] findAllTenants()                 { return []; }
    bool existsByTenant(TenantId tenantId)      { return !isTenantEmpty(tenantId); }
    size_t countByTenant(TenantId tenantId)     { return find(tenantId).length; }
    ServiceInstance[] filterByTenant(ServiceInstance[] items, TenantId tenantId) {
        return items.filter!(e => e.tenantId == tenantId).array;
    }
    void removeByTenant(TenantId tenantId) @trusted {
        _collection.remove(Bson(["tenantId": Bson(tenantId.value)]));
    }

    ServiceInstance[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) @trusted {
        ServiceInstance[] result;
        foreach (doc; _collection.find(Bson(["tenantId": Bson(tenantId.value)])))
            result ~= fromBson(doc);
        return result;
    }

    bool existsById(TenantId tenantId, ServiceInstanceId id) @trusted {
        return !_collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)])).isNull;
    }

    ServiceInstance findById(TenantId tenantId, ServiceInstanceId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
        if (doc.isNull) return ServiceInstance.init;
        return fromBson(doc);
    }

    void removeById(TenantId tenantId, ServiceInstanceId id) @trusted {
        _collection.remove(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
    }

    bool existsAllById(TenantId tenantId, ServiceInstanceId[] ids) {
        import std.algorithm : all;
        return ids.all!(id => existsById(tenantId, id));
    }

    ServiceInstance[] findAllById(TenantId tenantId, ServiceInstanceId[] ids) {
        ServiceInstance[] result;
        foreach (id; ids) {
            auto e = findById(tenantId, id);
            if (e.id.value.length > 0) result ~= e;
        }
        return result;
    }

    void removeAllById(TenantId tenantId, ServiceInstanceId[] ids) {
        foreach (id; ids) removeById(tenantId, id);
    }

    void save(ServiceInstance item) @trusted {
        auto query = Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]);
        _collection.update(query, Bson(["$set": toBson(item)]), UpdateFlags.upsert);
    }

    void saveAll(ServiceInstance[] items) { foreach (i; items) save(i); }

    void update(ServiceInstance item) { save(item); }
    void updateAll(ServiceInstance[] items) { foreach (i; items) update(i); }

    bool exists(ServiceInstance item)    { return existsById(item.tenantId, item.id); }
    void remove(ServiceInstance item)    { removeById(item.tenantId, item.id); }
    void removeAll(ServiceInstance[] items) { foreach (i; items) remove(i); }

    size_t countAll()                     { return findAll().length; }
    size_t indexOf(ServiceInstance item)  { return size_t.max; }

    ServiceInstance[] findAll(size_t offset = 0, size_t limit = 0) @trusted {
        ServiceInstance[] result;
        foreach (doc; _collection.find(Bson.emptyObject)) result ~= fromBson(doc);
        return result;
    }

    void removeAll() @trusted { _collection.remove(Bson.emptyObject); }

    // --- ServiceInstanceRepository ---
    override ServiceInstance[] findByStatus(TenantId tenantId, InstanceStatus status) {
        return find(tenantId).filter!(e => e.status == status).array;
    }

    override ServiceInstance[] findByPlan(TenantId tenantId, ServicePlanId planId) {
        return find(tenantId).filter!(e => e.planId == planId).array;
    }

    override ServiceInstance[] findByHyperscaler(TenantId tenantId, Hyperscaler hs) {
        return find(tenantId).filter!(e => e.hyperscaler == hs).array;
    }

    override bool nameExists(TenantId tenantId, string name) {
        return find(tenantId).any!(e => e.name == name);
    }
}
