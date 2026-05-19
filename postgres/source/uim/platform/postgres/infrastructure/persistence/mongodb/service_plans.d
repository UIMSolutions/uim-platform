/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.mongodb.service_plans;

import uim.platform.postgres;
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
        ServicePlan e;
        e.id               = ServicePlanId(doc["id"].get!string);
        e.tenantId         = TenantId(doc["tenantId"].get!string);
        e.name             = doc["name"].get!string;
        e.description      = doc["description"].get!string;
        e.tier             = doc["tier"].get!string.to!PlanTier;
        e.memoryGb         = doc["memoryGb"].get!long;
        e.storageGb        = doc["storageGb"].get!long;
        e.maxConnections   = doc["maxConnections"].get!long;
        e.multiAzSupported = doc["multiAzSupported"].get!bool;
        e.available        = doc["available"].get!bool;
        e.pricingUnit      = doc["pricingUnit"].get!string;
        e.createdAt        = doc["createdAt"].get!long;
        e.createdBy        = UserId(doc["createdBy"].get!string);
        e.updatedBy        = UserId(doc["updatedBy"].get!string);
        return e;
    }

    private Bson toBson(ServicePlan e) {
        return Bson([
            "id":               Bson(e.id.value),
            "tenantId":         Bson(e.tenantId.value),
            "name":             Bson(e.name),
            "description":      Bson(e.description),
            "tier":             Bson(e.tier.to!string),
            "memoryGb":         Bson(e.memoryGb),
            "storageGb":        Bson(e.storageGb),
            "maxConnections":   Bson(e.maxConnections),
            "multiAzSupported": Bson(e.multiAzSupported),
            "available":        Bson(e.available),
            "pricingUnit":      Bson(e.pricingUnit),
            "createdAt":        Bson(e.createdAt),
            "createdBy":        Bson(e.createdBy.value),
            "updatedBy":        Bson(e.updatedBy.value)
        ]);
    }

    bool isTenantEmpty(TenantId t)         { return findByTenant(t).length == 0; }
    void createTenant(TenantId t)           {}
    TenantId[] findAllTenants()             { return []; }
    bool existsByTenant(TenantId t)         { return !isTenantEmpty(t); }
    size_t countByTenant(TenantId t)        { return findByTenant(t).length; }
    ServicePlan[] filterByTenant(ServicePlan[] items, TenantId t) {
        return items.filter!(e => e.tenantId == t).array;
    }
    void removeByTenant(TenantId t) @trusted {
        _collection.remove(Bson(["tenantId": Bson(t.value)]));
    }
    ServicePlan[] findByTenant(TenantId t, size_t offset = 0, size_t limit = 0) @trusted {
        ServicePlan[] result;
        foreach (doc; _collection.find(Bson(["tenantId": Bson(t.value)]))) result ~= fromBson(doc);
        return result;
    }
    bool existsById(TenantId t, ServicePlanId id) @trusted {
        return !_collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])).isNull;
    }
    ServicePlan findById(TenantId t, ServicePlanId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
        if (doc.isNull) return ServicePlan.init;
        return fromBson(doc);
    }
    void removeById(TenantId t, ServicePlanId id) @trusted {
        _collection.remove(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
    }
    bool existsAllById(TenantId t, ServicePlanId[] ids) {
        import std.algorithm : all;
        return ids.all!(id => existsById(t, id));
    }
    ServicePlan[] findAllById(TenantId t, ServicePlanId[] ids) {
        ServicePlan[] result;
        foreach (id; ids) { auto e = findById(t, id); if (e.id.value.length > 0) result ~= e; }
        return result;
    }
    void removeAllById(TenantId t, ServicePlanId[] ids) { foreach (id; ids) removeById(t, id); }
    void save(ServicePlan item) @trusted {
        auto q = Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]);
        _collection.update(q, Bson(["$set": toBson(item)]), UpdateFlags.upsert);
    }
    void saveAll(ServicePlan[] items)     { foreach (i; items) save(i); }
    void update(ServicePlan item)         { save(item); }
    void updateAll(ServicePlan[] items)   { foreach (i; items) update(i); }
    bool exists(ServicePlan item)         { return existsById(item.tenantId, item.id); }
    void remove(ServicePlan item)         { removeById(item.tenantId, item.id); }
    void removeAll(ServicePlan[] items)   { foreach (i; items) remove(i); }
    size_t countAll()                     { return findAll().length; }
    size_t indexOf(ServicePlan item)      { return size_t.max; }
    ServicePlan[] findAll(size_t offset = 0, size_t limit = 0) @trusted {
        ServicePlan[] result;
        foreach (doc; _collection.find(Bson.emptyObject)) result ~= fromBson(doc);
        return result;
    }
    void removeAll() @trusted { _collection.remove(Bson.emptyObject); }

    override ServicePlan[] findByTier(TenantId t, PlanTier tier) {
        return findByTenant(t).filter!(e => e.tier == tier).array;
    }
    override ServicePlan[] findAvailable(TenantId t) {
        return findByTenant(t).filter!(e => e.available).array;
    }
    override bool nameExists(TenantId t, string name) {
        return findByTenant(t).any!(e => e.name == name);
    }
}
