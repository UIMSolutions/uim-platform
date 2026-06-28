/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.mongodb.system_registrations;

import uim.platform.service;
import uim.platform.appevents.domain.entities.system_registration;
import uim.platform.appevents.domain.repositories.system_registrations;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.system_type;
import uim.platform.appevents.domain.enums.system_status;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter, any;
import std.array     : array;
import std.conv      : to;

@safe:

class MongoSystemRegistrationRepository : SystemRegistrationRepository {
    private MongoCollection _collection;

    this(MongoCollection collection) { _collection = collection; }

    private SystemRegistration fromBson(Bson doc) {
        SystemRegistration r;
        r.id           = SystemRegistrationId(doc["id"].get!string);
        r.tenantId     = TenantId(doc["tenantId"].get!string);
        r.formationId  = FormationId(doc["formationId"].get!string);
        r.systemId     = doc["systemId"].get!string;
        r.systemType   = doc["systemType"].get!string.to!SystemType;
        r.systemUrl    = doc["systemUrl"].get!string;
        r.status       = doc["status"].get!string.to!SystemStatus;
        r.registeredAt = doc["registeredAt"].get!long;
        r.createdAt    = doc["createdAt"].get!long;
        r.createdBy    = UserId(doc["createdBy"].get!string);
        return r;
    }

    private Bson toBson(SystemRegistration r) {
        return Bson([
            "id":           Bson(r.id.value),
            "tenantId":     Bson(r.tenantId.value),
            "formationId":  Bson(r.formationId.value),
            "systemId":     Bson(r.systemId),
            "systemType":   Bson(r.systemType.to!string),
            "systemUrl":    Bson(r.systemUrl),
            "status":       Bson(r.status.to!string),
            "registeredAt": Bson(r.registeredAt),
            "createdAt":    Bson(r.createdAt),
            "createdBy":    Bson(r.createdBy.value)
        ]);
    }

    bool isTenantEmpty(TenantId tenantId)  { return find(tenantId).length == 0; }
    void createTenant(TenantId tenantId)    {}
    TenantId[] findAllTenants()             { return []; }
    bool existsByTenant(TenantId tenantId)  { return !isTenantEmpty(tenantId); }
    size_t countByTenant(TenantId tenantId) { return find(tenantId).length; }
    SystemRegistration[] filterByTenant(SystemRegistration[] items, TenantId tenantId) {
        return items.filter!(e => e.tenantId == tenantId).array;
    }
    void removeByTenant(TenantId tenantId) @trusted {
        _collection.remove(Bson(["tenantId": Bson(tenantId.value)]));
    }

    SystemRegistration[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) @trusted {
        SystemRegistration[] result;
        foreach (doc; _collection.find(Bson(["tenantId": Bson(tenantId.value)])))
            result ~= fromBson(doc);
        return result;
    }

    bool existsById(TenantId tenantId, SystemRegistrationId id) @trusted {
        return !_collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)])).isNull;
    }

    SystemRegistration findById(TenantId tenantId, SystemRegistrationId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
        if (doc.isNull) return SystemRegistration.init;
        return fromBson(doc);
    }

    void removeById(TenantId tenantId, SystemRegistrationId id) @trusted {
        _collection.remove(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
    }

    bool existsAllById(TenantId tenantId, SystemRegistrationId[] ids) {
        import std.algorithm : all;
        return ids.all!(id => existsById(tenantId, id));
    }

    SystemRegistration[] findAllById(TenantId tenantId, SystemRegistrationId[] ids) {
        SystemRegistration[] result;
        foreach (id; ids) {
            auto e = find(tenantId, id);
            if (!e.isNull) result ~= e;
        }
        return result;
    }

    void removeAllById(TenantId tenantId, SystemRegistrationId[] ids) { foreach (id; ids) removeById(tenantId, id); }

    void save(SystemRegistration item) @trusted {
        auto query = Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]);
        _collection.update(query, Bson(["$set": toBson(item)]), UpdateFlags.upsert);
    }

    void saveAll(SystemRegistration[] items) { foreach (i; items) save(i); }
    void update(SystemRegistration item) { save(item); }
    void updateAll(SystemRegistration[] items) { foreach (i; items) update(i); }
    bool exists(SystemRegistration item)  { return existsById(item.tenantId, item.id); }
    void remove(SystemRegistration item)  { removeById(item.tenantId, item.id); }
    void removeAll(SystemRegistration[] items) { foreach (i; items) remove(i); }
    size_t countAll()                     { return findAll().length; }
    size_t indexOf(SystemRegistration item){ return size_t.max; }

    SystemRegistration[] findAll(size_t offset = 0, size_t limit = 0) @trusted {
        SystemRegistration[] result;
        foreach (doc; _collection.find(Bson.emptyObject)) result ~= fromBson(doc);
        return result;
    }

    void removeAll() @trusted { _collection.remove(Bson.emptyObject); }

    override SystemRegistration[] findByFormation(TenantId tenantId, FormationId formationId) {
        return find(tenantId).filter!(e => e.formationId.value == formationId.value).array;
    }

    override SystemRegistration[] findBySystemType(TenantId tenantId, SystemType systemType) {
        return find(tenantId).filter!(e => e.systemType == systemType).array;
    }

    override SystemRegistration[] findByStatus(TenantId tenantId, SystemStatus status) {
        return find(tenantId).filter!(e => e.status == status).array;
    }
}
