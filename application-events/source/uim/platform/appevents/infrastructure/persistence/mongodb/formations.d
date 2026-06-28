/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.mongodb.formations;

import uim.platform.service;
import uim.platform.appevents.domain.entities.formation;
import uim.platform.appevents.domain.repositories.formations;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.formation_status;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter, any;
import std.array     : array;
import std.conv      : to;

@safe:

class MongoFormationRepository : FormationRepository {
    private MongoCollection _collection;

    this(MongoCollection collection) { _collection = collection; }

    private Formation fromBson(Bson doc) {
        Formation f;
        f.id              = FormationId(doc["id"].get!string);
        f.tenantId        = TenantId(doc["tenantId"].get!string);
        f.name            = doc["name"].get!string;
        f.description     = doc["description"].get!string;
        f.globalAccountId = doc["globalAccountId"].get!string;
        f.status          = doc["status"].get!string.to!FormationStatus;
        f.systemCount     = cast(int) doc["systemCount"].get!long;
        f.createdAt       = doc["createdAt"].get!long;
        f.updatedAt       = doc["updatedAt"].get!long;
        f.createdBy       = UserId(doc["createdBy"].get!string);
        f.updatedBy       = UserId(doc["updatedBy"].get!string);
        return f;
    }

    private Bson toBson(Formation f) {
        return Bson([
            "id":              Bson(f.id.value),
            "tenantId":        Bson(f.tenantId.value),
            "name":            Bson(f.name),
            "description":     Bson(f.description),
            "globalAccountId": Bson(f.globalAccountId),
            "status":          Bson(f.status.to!string),
            "systemCount":     Bson(cast(long) f.systemCount),
            "createdAt":       Bson(f.createdAt),
            "updatedAt":       Bson(f.updatedAt),
            "createdBy":       Bson(f.createdBy.value),
            "updatedBy":       Bson(f.updatedBy.value)
        ]);
    }

    bool isTenantEmpty(TenantId tenantId)  { return find(tenantId).length == 0; }
    void createTenant(TenantId tenantId)    {}
    TenantId[] findAllTenants()             { return []; }
    bool existsByTenant(TenantId tenantId)  { return !isTenantEmpty(tenantId); }
    size_t countByTenant(TenantId tenantId) { return find(tenantId).length; }
    Formation[] filterByTenant(Formation[] items, TenantId tenantId) {
        return items.filter!(e => e.tenantId == tenantId).array;
    }
    void removeByTenant(TenantId tenantId) @trusted {
        _collection.remove(Bson(["tenantId": Bson(tenantId.value)]));
    }

    Formation[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) @trusted {
        Formation[] result;
        foreach (doc; _collection.find(Bson(["tenantId": Bson(tenantId.value)])))
            result ~= fromBson(doc);
        return result;
    }

    bool existsById(TenantId tenantId, FormationId id) @trusted {
        return !_collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)])).isNull;
    }

    Formation findById(TenantId tenantId, FormationId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
        if (doc.isNull) return Formation.init;
        return fromBson(doc);
    }

    void removeById(TenantId tenantId, FormationId id) @trusted {
        _collection.remove(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
    }

    bool existsAllById(TenantId tenantId, FormationId[] ids) {
        import std.algorithm : all;
        return ids.all!(id => existsById(tenantId, id));
    }

    Formation[] findAllById(TenantId tenantId, FormationId[] ids) {
        Formation[] result;
        foreach (id; ids) {
            auto e = findById(tenantId, id);
            if (!e.isNull) result ~= e;
        }
        return result;
    }

    void removeAllById(TenantId tenantId, FormationId[] ids) { foreach (id; ids) removeById(tenantId, id); }

    void save(Formation item) @trusted {
        auto query = Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]);
        _collection.update(query, Bson(["$set": toBson(item)]), UpdateFlags.upsert);
    }

    void saveAll(Formation[] items) { foreach (i; items) save(i); }
    void update(Formation item) { save(item); }
    void updateAll(Formation[] items) { foreach (i; items) update(i); }
    bool exists(Formation item)  { return existsById(item.tenantId, item.id); }
    void remove(Formation item)  { removeById(item.tenantId, item.id); }
    void removeAll(Formation[] items) { foreach (i; items) remove(i); }
    size_t countAll()             { return findAll().length; }
    size_t indexOf(Formation item){ return size_t.max; }

    Formation[] findAll(size_t offset = 0, size_t limit = 0) @trusted {
        Formation[] result;
        foreach (doc; _collection.find(Bson.emptyObject)) result ~= fromBson(doc);
        return result;
    }

    void removeAll() @trusted { _collection.remove(Bson.emptyObject); }

    override Formation[] findByStatus(TenantId tenantId, FormationStatus status) {
        return find(tenantId).filter!(e => e.status == status).array;
    }

    override Formation[] findByGlobalAccount(TenantId tenantId, string globalAccountId) {
        return find(tenantId).filter!(e => e.globalAccountId == globalAccountId).array;
    }

    override bool nameExists(TenantId tenantId, string name) {
        return find(tenantId).any!(e => e.name == name);
    }
}
