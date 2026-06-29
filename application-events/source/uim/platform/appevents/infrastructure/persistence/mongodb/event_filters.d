/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.mongodb.event_filters;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_filter;
import uim.platform.appevents.domain.repositories.event_filters;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.filter_type;
import uim.platform.appevents.domain.enums.filter_operator;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter, any;
import std.array     : array;
import std.conv      : to;

@safe:

class MongoEventFilterRepository : EventFilterRepository {
    private MongoCollection _collection;

    this(MongoCollection collection) { _collection = collection; }

    private EventFilter fromBson(Bson doc) {
        EventFilter f;
        f.id             = EventFilterId(doc["id"].get!string);
        f.tenantId       = TenantId(doc["tenantId"].get!string);
        f.subscriptionId = EventSubscriptionId(doc["subscriptionId"].get!string);
        f.filterType     = doc["filterType"].get!string.to!FilterType;
        f.attribute      = doc["attribute"].get!string;
        f.operator_      = doc["operator"].get!string.to!FilterOperator;
        f.value          = doc["value"].get!string;
        f.active         = doc["active"].get!bool;
        f.createdAt      = doc["createdAt"].get!long;
        f.createdBy      = UserId(doc["createdBy"].get!string);
        return f;
    }

    private Bson toBson(EventFilter f) {
        return Bson([
            "id":             Bson(f.id.value),
            "tenantId":       Bson(f.tenantId.value),
            "subscriptionId": Bson(f.subscriptionId.value),
            "filterType":     Bson(f.filterType.to!string),
            "attribute":      Bson(f.attribute),
            "operator":       Bson(f.operator_.to!string),
            "value":          Bson(f.value),
            "active":         Bson(f.active),
            "createdAt":      Bson(f.createdAt),
            "createdBy":      Bson(f.createdBy.value)
        ]);
    }

    bool isTenantEmpty(TenantId tenantId)  { return findByTenant(tenantId).length == 0; }
    void createTenant(TenantId tenantId)    {}
    TenantId[] findAllTenants()             { return []; }
    bool existsByTenant(TenantId tenantId)  { return !isTenantEmpty(tenantId); }
    size_t countByTenant(TenantId tenantId) { return findByTenant(tenantId).length; }
    EventFilter[] filterByTenant(EventFilter[] items, TenantId tenantId) {
        return items.filter!(e => e.tenantId == tenantId).array;
    }
    void removeByTenant(TenantId tenantId) @trusted {
        _collection.remove(Bson(["tenantId": Bson(tenantId.value)]));
    }

    EventFilter[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) @trusted {
        EventFilter[] result;
        foreach (doc; _collection.find(Bson(["tenantId": Bson(tenantId.value)])))
            result ~= fromBson(doc);
        return result;
    }

    bool existsById(TenantId tenantId, EventFilterId id) @trusted {
        return !_collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)])).isNull;
    }

    EventFilter findById(TenantId tenantId, EventFilterId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
        if (doc.isNull) return EventFilter.init;
        return fromBson(doc);
    }

    void removeById(TenantId tenantId, EventFilterId id) @trusted {
        _collection.remove(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
    }

    bool existsAllById(TenantId tenantId, EventFilterId[] ids) {
        import std.algorithm : all;
        return ids.all!(id => existsById(tenantId, id));
    }

    EventFilter[] findAllById(TenantId tenantId, EventFilterId[] ids) {
        EventFilter[] result;
        foreach (id; ids) {
            auto e = findById(tenantId, id);
            if (!e.isNull) result ~= e;
        }
        return result;
    }

    void removeAllById(TenantId tenantId, EventFilterId[] ids) { foreach (id; ids) removeById(tenantId, id); }

    void save(EventFilter item) @trusted {
        auto query = Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]);
        _collection.update(query, Bson(["$set": toBson(item)]), UpdateFlags.upsert);
    }

    void saveAll(EventFilter[] items) { foreach (i; items) save(i); }
    void update(EventFilter item) { save(item); }
    void updateAll(EventFilter[] items) { foreach (i; items) update(i); }
    bool exists(EventFilter item)  { return existsById(item.tenantId, item.id); }
    void remove(EventFilter item)  { removeById(item.tenantId, item.id); }
    void removeAll(EventFilter[] items) { foreach (i; items) remove(i); }
    size_t countAll()               { return findAll().length; }
    size_t indexOf(EventFilter item){ return size_t.max; }

    EventFilter[] findAll(size_t offset = 0, size_t limit = 0) @trusted {
        EventFilter[] result;
        foreach (doc; _collection.find(Bson.emptyObject)) result ~= fromBson(doc);
        return result;
    }

    void removeAll() @trusted { _collection.remove(Bson.emptyObject); }

    override EventFilter[] findBySubscription(TenantId tenantId, EventSubscriptionId subscriptionId) {
        return findByTenant(tenantId).filter!(e => e.subscriptionId.value == subscriptionId.value).array;
    }

    override EventFilter[] findActive(TenantId tenantId) {
        return findByTenant(tenantId).filter!(e => e.active).array;
    }
}
