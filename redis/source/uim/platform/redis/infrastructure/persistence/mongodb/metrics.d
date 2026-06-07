/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.mongodb.metrics;

import uim.platform.redis;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter;
import std.array     : array;
import std.conv      : to;

// mixin(ShowModule!());

@safe:

class MongoMetricRepository : MetricRepository {
    private MongoCollection _collection;
    this(MongoCollection collection) { _collection = collection; }

    private Metric fromBson(Bson doc) {
        Metric m;
        m.id         = MetricId(doc["id"].get!string);
        m.tenantId   = TenantId(doc["tenantId"].get!string);
        m.instanceId = ServiceInstanceId(doc["instanceId"].get!string);
        m.timestamp_ = doc["timestamp"].get!long;
        m.memoryUsedMb  = doc["memoryUsedMb"].get!long;
        m.memoryTotalMb = doc["memoryTotalMb"].get!long;
        m.connectedClients = doc["connectedClients"].get!long;
        m.commandsPerSecond = doc["commandsPerSecond"].get!long;
        m.hitRate    = doc["hitRate"].get!double;
        m.evictedKeys = doc["evictedKeys"].get!long;
        m.expiredKeys = doc["expiredKeys"].get!long;
        m.totalCommandsProcessed = doc["totalCommandsProcessed"].get!long;
        m.cpuUsagePercent = doc["cpuUsagePercent"].get!double;
        m.networkInputKbs = doc["networkInputKbs"].get!long;
        m.networkOutputKbs = doc["networkOutputKbs"].get!long;
        m.createdAt  = doc["createdAt"].get!long;
        return m;
    }
    private Bson toBson(Metric m) {
        return Bson(["id": Bson(m.id.value), "tenantId": Bson(m.tenantId.value),
            "instanceId": Bson(m.instanceId.value), "timestamp": Bson(m.timestamp_),
            "memoryUsedMb": Bson(m.memoryUsedMb), "memoryTotalMb": Bson(m.memoryTotalMb),
            "connectedClients": Bson(m.connectedClients), "commandsPerSecond": Bson(m.commandsPerSecond),
            "hitRate": Bson(m.hitRate), "evictedKeys": Bson(m.evictedKeys), "expiredKeys": Bson(m.expiredKeys),
            "totalCommandsProcessed": Bson(m.totalCommandsProcessed), "cpuUsagePercent": Bson(m.cpuUsagePercent),
            "networkInputKbs": Bson(m.networkInputKbs), "networkOutputKbs": Bson(m.networkOutputKbs),
            "createdAt": Bson(m.createdAt)]);
    }

    bool isTenantEmpty(TenantId t)                       { return findByTenant(t).length == 0; }
    void createTenant(TenantId t)                        {}
    TenantId[] findAllTenants()                          { return []; }
    bool existsByTenant(TenantId t)                      { return !isTenantEmpty(t); }
    size_t countByTenant(TenantId t)                     { return findByTenant(t).length; }
    Metric[] filterByTenant(Metric[] items, TenantId t)  { return items.filter!(e => e.tenantId == t).array; }
    void removeByTenant(TenantId t) @trusted             { _collection.remove(Bson(["tenantId": Bson(t.value)])); }
    Metric[] findByTenant(TenantId t, size_t o = 0, size_t l = 0) @trusted {
        Metric[] r; foreach (doc; _collection.find(Bson(["tenantId": Bson(t.value)]))) r ~= fromBson(doc); return r;
    }
    bool existsById(TenantId t, MetricId id) @trusted { return !_collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])).isNull; }
    Metric findById(TenantId t, MetricId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
        return doc.isNull ? Metric.init : fromBson(doc);
    }
    void removeById(TenantId t, MetricId id) @trusted { _collection.remove(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])); }
    bool existsAllById(TenantId t, MetricId[] ids) { import std.algorithm : all; return ids.all!(id => existsById(t, id)); }
    Metric[] findAllById(TenantId t, MetricId[] ids) { Metric[] r; foreach (id; ids) { auto e = findById(t, id); if (e.id.value.length > 0) r ~= e; } return r; }
    void removeAllById(TenantId t, MetricId[] ids) { foreach (id; ids) removeById(t, id); }
    void save(Metric item) @trusted { _collection.update(Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]), Bson(["$set": toBson(item)]), UpdateFlags.upsert); }
    void saveAll(Metric[] items) { foreach (i; items) save(i); }
    void update(Metric item) { save(item); }
    void updateAll(Metric[] items) { foreach (i; items) update(i); }
    bool exists(Metric item)  { return existsById(item.tenantId, item.id); }
    void remove(Metric item)  { removeById(item.tenantId, item.id); }
    void removeAll(Metric[] items) { foreach (i; items) remove(i); }
    size_t countAll()         { return findAll().length; }
    size_t indexOf(Metric i)  { return size_t.max; }
    Metric[] findAll(size_t o = 0, size_t l = 0) @trusted { Metric[] r; foreach (doc; _collection.find(Bson.emptyObject)) r ~= fromBson(doc); return r; }
    void removeAll() @trusted { _collection.remove(Bson.emptyObject); }

    override Metric[] findByInstance(TenantId t, ServiceInstanceId iid) { return findByTenant(t).filter!(e => e.instanceId == iid).array; }
    override Metric[] findByInstanceAndTimeRange(TenantId t, ServiceInstanceId iid, long from, long to_) {
        return findByTenant(t).filter!(e => e.instanceId == iid && e.timestamp_ >= from && e.timestamp_ <= to_).array;
    }
    override Metric findLatestByInstance(TenantId t, ServiceInstanceId iid) {
        auto items = findByInstance(t, iid);
        if (items.length == 0) return Metric.init;
        Metric latest = items[0];
        foreach (m; items) if (m.timestamp_ > latest.timestamp_) latest = m;
        return latest;
    }
}
