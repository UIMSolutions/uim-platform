/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.infrastructure.persistence.mongodb.service_plans;

import uim.platform.redis;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter, any;
import std.array     : array;
import std.conv      : to;
mixin(ShowModule!());

@safe:

class MongoServicePlanRepository : ServicePlanRepository {
    private MongoCollection _collection;
    this(MongoCollection collection) { _collection = collection; }

    private ServicePlan fromBson(Bson doc) {
        ServicePlan p;
        p.id          = ServicePlanId(doc["id"].get!string);
        p.tenantId    = TenantId(doc["tenantId"].get!string);
        p.name        = doc["name"].get!string;
        p.description = doc["description"].get!string;
        p.tier        = doc["tier"].get!string.to!PlanTier;
        p.memoryMb    = doc["memoryMb"].get!long;
        p.maxConnections = doc["maxConnections"].get!long;
        p.haEnabled   = doc["haEnabled"].get!bool;
        p.persistenceEnabled = doc["persistenceEnabled"].get!bool;
        p.tlsEnabled  = doc["tlsEnabled"].get!bool;
        p.pricingUnit = doc["pricingUnit"].get!string;
        p.available   = doc["available"].get!bool;
        p.createdAt   = doc["createdAt"].get!long;
        return p;
    }
    private Bson toBson(ServicePlan p) {
        return Bson(["id": Bson(p.id.value), "tenantId": Bson(p.tenantId.value), "name": Bson(p.name),
            "description": Bson(p.description), "tier": Bson(p.tier.to!string), "memoryMb": Bson(p.memoryMb),
            "maxConnections": Bson(p.maxConnections), "haEnabled": Bson(p.haEnabled),
            "persistenceEnabled": Bson(p.persistenceEnabled), "tlsEnabled": Bson(p.tlsEnabled),
            "pricingUnit": Bson(p.pricingUnit), "available": Bson(p.available), "createdAt": Bson(p.createdAt)]);
    }

    bool isTenantEmpty(TenantId t)                          { return findByTenant(t).length == 0; }
    void createTenant(TenantId t)                           {}
    TenantId[] findAllTenants()                             { return []; }
    bool existsByTenant(TenantId t)                         { return !isTenantEmpty(t); }
    size_t countByTenant(TenantId t)                        { return findByTenant(t).length; }
    ServicePlan[] filterByTenant(ServicePlan[] items, TenantId t) { return items.filter!(e => e.tenantId == t).array; }
    void removeByTenant(TenantId t) @trusted               { _collection.remove(Bson(["tenantId": Bson(t.value)])); }
    ServicePlan[] findByTenant(TenantId t, size_t o = 0, size_t l = 0) @trusted {
        ServicePlan[] r; foreach (doc; _collection.find(Bson(["tenantId": Bson(t.value)]))) r ~= fromBson(doc); return r;
    }
    bool existsById(TenantId t, ServicePlanId id) @trusted { return !_collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])).isNull; }
    ServicePlan findById(TenantId t, ServicePlanId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
        return doc.isNull ? ServicePlan.init : fromBson(doc);
    }
    void removeById(TenantId t, ServicePlanId id) @trusted { _collection.remove(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])); }
    bool existsAllById(TenantId t, ServicePlanId[] ids) { import std.algorithm : all; return ids.all!(id => existsById(t, id)); }
    ServicePlan[] findAllById(TenantId t, ServicePlanId[] ids) { ServicePlan[] r; foreach (id; ids) { auto e = findById(t, id); if (e.id.value.length > 0) r ~= e; } return r; }
    void removeAllById(TenantId t, ServicePlanId[] ids) { foreach (id; ids) removeById(t, id); }
    void save(ServicePlan item) @trusted { _collection.update(Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]), Bson(["$set": toBson(item)]), UpdateFlags.upsert); }
    void saveAll(ServicePlan[] items) { foreach (i; items) save(i); }
    void update(ServicePlan item) { save(item); }
    void updateAll(ServicePlan[] items) { foreach (i; items) update(i); }
    bool exists(ServicePlan item)  { return existsById(item.tenantId, item.id); }
    void remove(ServicePlan item)  { removeById(item.tenantId, item.id); }
    void removeAll(ServicePlan[] items) { foreach (i; items) remove(i); }
    size_t countAll()              { return findAll().length; }
    size_t indexOf(ServicePlan i)  { return size_t.max; }
    ServicePlan[] findAll(size_t o = 0, size_t l = 0) @trusted { ServicePlan[] r; foreach (doc; _collection.find(Bson.emptyObject)) r ~= fromBson(doc); return r; }
    void removeAll() @trusted     { _collection.remove(Bson.emptyObject); }

    override ServicePlan[] findByTier(TenantId t, PlanTier tier)    { return findByTenant(t).filter!(e => e.tier == tier).array; }
    override ServicePlan[] findAvailable(TenantId t)                { return findByTenant(t).filter!(e => e.available).array; }
    override bool nameExists(TenantId t, string name)               { return findByTenant(t).any!(e => e.name == name); }
}
