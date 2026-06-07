/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.mongodb.maintenance_windows;

import uim.platform.postgres;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter;
import std.array     : array;
import std.conv      : to;

// mixin(ShowModule!());

@safe:

class MongoMaintenanceWindowRepository : MaintenanceWindowRepository {
    private MongoCollection _collection;
    this(MongoCollection collection) { _collection = collection; }

    private MaintenanceWindow fromBson(Bson doc) {
        MaintenanceWindow e;
        e.id                      = MaintenanceWindowId(doc["id"].get!string);
        e.tenantId                = TenantId(doc["tenantId"].get!string);
        e.instanceId              = ServiceInstanceId(doc["instanceId"].get!string);
        e.dayOfWeek               = doc["dayOfWeek"].get!string;
        e.startHourUtc            = doc["startHourUtc"].get!long;
        e.durationHours           = doc["durationHours"].get!long;
        e.autoMinorVersionUpgrade = doc["autoMinorVersionUpgrade"].get!bool;
        e.status                  = doc["status"].get!string.to!MaintenanceStatus;
        e.lastMaintenanceAt       = doc["lastMaintenanceAt"].get!long;
        e.nextMaintenanceAt       = doc["nextMaintenanceAt"].get!long;
        e.createdAt               = doc["createdAt"].get!long;
        e.createdBy               = UserId(doc["createdBy"].get!string);
        e.updatedBy               = UserId(doc["updatedBy"].get!string);
        return e;
    }

    private Bson toBson(MaintenanceWindow e) {
        return Bson([
            "id":                      Bson(e.id.value),
            "tenantId":                Bson(e.tenantId.value),
            "instanceId":              Bson(e.instanceId.value),
            "dayOfWeek":               Bson(e.dayOfWeek),
            "startHourUtc":            Bson(e.startHourUtc),
            "durationHours":           Bson(e.durationHours),
            "autoMinorVersionUpgrade": Bson(e.autoMinorVersionUpgrade),
            "status":                  Bson(e.status.to!string),
            "lastMaintenanceAt":       Bson(e.lastMaintenanceAt),
            "nextMaintenanceAt":       Bson(e.nextMaintenanceAt),
            "createdAt":               Bson(e.createdAt),
            "createdBy":               Bson(e.createdBy.value),
            "updatedBy":               Bson(e.updatedBy.value)
        ]);
    }

    bool isTenantEmpty(TenantId t)              { return findByTenant(t).length == 0; }
    void createTenant(TenantId t)                {}
    TenantId[] findAllTenants()                  { return []; }
    bool existsByTenant(TenantId t)              { return !isTenantEmpty(t); }
    size_t countByTenant(TenantId t)             { return findByTenant(t).length; }
    MaintenanceWindow[] filterByTenant(MaintenanceWindow[] items, TenantId t) {
        return items.filter!(e => e.tenantId == t).array;
    }
    void removeByTenant(TenantId t) @trusted {
        _collection.remove(Bson(["tenantId": Bson(t.value)]));
    }
    MaintenanceWindow[] findByTenant(TenantId t, size_t offset = 0, size_t limit = 0) @trusted {
        MaintenanceWindow[] result;
        foreach (doc; _collection.find(Bson(["tenantId": Bson(t.value)]))) result ~= fromBson(doc);
        return result;
    }
    bool existsById(TenantId t, MaintenanceWindowId id) @trusted {
        return !_collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])).isNull;
    }
    MaintenanceWindow findById(TenantId t, MaintenanceWindowId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
        if (doc.isNull) return MaintenanceWindow.init;
        return fromBson(doc);
    }
    void removeById(TenantId t, MaintenanceWindowId id) @trusted {
        _collection.remove(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
    }
    bool existsAllById(TenantId t, MaintenanceWindowId[] ids) {
        import std.algorithm : all;
        return ids.all!(id => existsById(t, id));
    }
    MaintenanceWindow[] findAllById(TenantId t, MaintenanceWindowId[] ids) {
        MaintenanceWindow[] result;
        foreach (id; ids) { auto e = findById(t, id); if (e.id.value.length > 0) result ~= e; }
        return result;
    }
    void removeAllById(TenantId t, MaintenanceWindowId[] ids) { foreach (id; ids) removeById(t, id); }
    void save(MaintenanceWindow item) @trusted {
        auto q = Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]);
        _collection.update(q, Bson(["$set": toBson(item)]), UpdateFlags.upsert);
    }
    void saveAll(MaintenanceWindow[] items)     { foreach (i; items) save(i); }
    void update(MaintenanceWindow item)         { save(item); }
    void updateAll(MaintenanceWindow[] items)   { foreach (i; items) update(i); }
    bool exists(MaintenanceWindow item)         { return existsById(item.tenantId, item.id); }
    void remove(MaintenanceWindow item)         { removeById(item.tenantId, item.id); }
    void removeAll(MaintenanceWindow[] items)   { foreach (i; items) remove(i); }
    size_t countAll()                           { return findAll().length; }
    size_t indexOf(MaintenanceWindow item)      { return size_t.max; }
    MaintenanceWindow[] findAll(size_t offset = 0, size_t limit = 0) @trusted {
        MaintenanceWindow[] result;
        foreach (doc; _collection.find(Bson.emptyObject)) result ~= fromBson(doc);
        return result;
    }
    void removeAll() @trusted { _collection.remove(Bson.emptyObject); }

    override MaintenanceWindow findByInstance(TenantId t, ServiceInstanceId instanceId) {
        auto r = findByTenant(t).filter!(e => e.instanceId == instanceId).array;
        return r.length > 0 ? r[0] : MaintenanceWindow.init;
    }
    override MaintenanceWindow[] findByStatus(TenantId t, MaintenanceStatus status) {
        return findByTenant(t).filter!(e => e.status == status).array;
    }
}
