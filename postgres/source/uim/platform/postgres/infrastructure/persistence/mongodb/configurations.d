/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.infrastructure.persistence.mongodb.configurations;

import uim.platform.postgres;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter;
import std.array     : array;

mixin(ShowModule!());

@safe:

class MongoConfigurationRepository : ConfigurationRepository {
    private MongoCollection _collection;
    this(MongoCollection collection) { _collection = collection; }

    private Configuration fromBson(Bson doc) {
        Configuration e;
        e.id                         = ConfigurationId(doc["id"].get!string);
        e.tenantId                   = TenantId(doc["tenantId"].get!string);
        e.instanceId                 = ServiceInstanceId(doc["instanceId"].get!string);
        e.auditLogLevels             = doc["auditLogLevels"].get!string;
        e.backupRetentionPeriod      = doc["backupRetentionPeriod"].get!long;
        e.locale                     = doc["locale"].get!string;
        e.maxConnections             = doc["maxConnections"].get!long;
        e.workMem                    = doc["workMem"].get!long;
        e.sharedBuffersMb            = doc["sharedBuffersMb"].get!long;
        e.maintenanceWindowDay       = doc["maintenanceWindowDay"].get!string;
        e.maintenanceWindowStartHour = doc["maintenanceWindowStartHour"].get!long;
        e.maintenanceWindowDuration  = doc["maintenanceWindowDuration"].get!long;
        e.activeVersion              = doc["activeVersion"].get!string;
        e.createdAt                  = doc["createdAt"].get!long;
        e.createdBy                  = UserId(doc["createdBy"].get!string);
        e.updatedBy                  = UserId(doc["updatedBy"].get!string);
        return e;
    }

    private Bson toBson(Configuration e) {
        return Bson([
            "id":                         Bson(e.id.value),
            "tenantId":                   Bson(e.tenantId.value),
            "instanceId":                 Bson(e.instanceId.value),
            "auditLogLevels":             Bson(e.auditLogLevels),
            "backupRetentionPeriod":      Bson(e.backupRetentionPeriod),
            "locale":                     Bson(e.locale),
            "maxConnections":             Bson(e.maxConnections),
            "workMem":                    Bson(e.workMem),
            "sharedBuffersMb":            Bson(e.sharedBuffersMb),
            "maintenanceWindowDay":       Bson(e.maintenanceWindowDay),
            "maintenanceWindowStartHour": Bson(e.maintenanceWindowStartHour),
            "maintenanceWindowDuration":  Bson(e.maintenanceWindowDuration),
            "activeVersion":              Bson(e.activeVersion),
            "createdAt":                  Bson(e.createdAt),
            "createdBy":                  Bson(e.createdBy.value),
            "updatedBy":                  Bson(e.updatedBy.value)
        ]);
    }

    bool isTenantEmpty(TenantId t)          { return findByTenant(t).length == 0; }
    void createTenant(TenantId t)            {}
    TenantId[] findAllTenants()              { return []; }
    bool existsByTenant(TenantId t)          { return !isTenantEmpty(t); }
    size_t countByTenant(TenantId t)         { return findByTenant(t).length; }
    Configuration[] filterByTenant(Configuration[] items, TenantId t) {
        return items.filter!(e => e.tenantId == t).array;
    }
    void removeByTenant(TenantId t) @trusted {
        _collection.remove(Bson(["tenantId": Bson(t.value)]));
    }
    Configuration[] findByTenant(TenantId t, size_t offset = 0, size_t limit = 0) @trusted {
        Configuration[] result;
        foreach (doc; _collection.find(Bson(["tenantId": Bson(t.value)]))) result ~= fromBson(doc);
        return result;
    }
    bool existsById(TenantId t, ConfigurationId id) @trusted {
        return !_collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)])).isNull;
    }
    Configuration findById(TenantId t, ConfigurationId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
        if (doc.isNull) return Configuration.init;
        return fromBson(doc);
    }
    void removeById(TenantId t, ConfigurationId id) @trusted {
        _collection.remove(Bson(["tenantId": Bson(t.value), "id": Bson(id.value)]));
    }
    bool existsAllById(TenantId t, ConfigurationId[] ids) {
        import std.algorithm : all;
        return ids.all!(id => existsById(t, id));
    }
    Configuration[] findAllById(TenantId t, ConfigurationId[] ids) {
        Configuration[] result;
        foreach (id; ids) { auto e = findById(t, id); if (e.id.value.length > 0) result ~= e; }
        return result;
    }
    void removeAllById(TenantId t, ConfigurationId[] ids) { foreach (id; ids) removeById(t, id); }
    void save(Configuration item) @trusted {
        auto q = Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]);
        _collection.update(q, Bson(["$set": toBson(item)]), UpdateFlags.upsert);
    }
    void saveAll(Configuration[] items)     { foreach (i; items) save(i); }
    void update(Configuration item)         { save(item); }
    void updateAll(Configuration[] items)   { foreach (i; items) update(i); }
    bool exists(Configuration item)         { return existsById(item.tenantId, item.id); }
    void remove(Configuration item)         { removeById(item.tenantId, item.id); }
    void removeAll(Configuration[] items)   { foreach (i; items) remove(i); }
    size_t countAll()                       { return findAll().length; }
    size_t indexOf(Configuration item)      { return size_t.max; }
    Configuration[] findAll(size_t offset = 0, size_t limit = 0) @trusted {
        Configuration[] result;
        foreach (doc; _collection.find(Bson.emptyObject)) result ~= fromBson(doc);
        return result;
    }
    void removeAll() @trusted { _collection.remove(Bson.emptyObject); }

    override Configuration findByInstance(TenantId t, ServiceInstanceId instanceId) {
        auto r = findByTenant(t).filter!(e => e.instanceId == instanceId).array;
        return r.length > 0 ? r[0] : Configuration.init;
    }
}
