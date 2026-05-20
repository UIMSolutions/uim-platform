/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.mongodb.event_subscriptions;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_subscription;
import uim.platform.appevents.domain.repositories.event_subscriptions;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.subscription_status;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter, any;
import std.array     : array;
import std.conv      : to;

@safe:

class MongoEventSubscriptionRepository : EventSubscriptionRepository {
    private MongoCollection _collection;

    this(MongoCollection collection) { _collection = collection; }

    private EventSubscription fromBson(Bson doc) {
        EventSubscription s;
        s.id                = EventSubscriptionId(doc["id"].get!string);
        s.tenantId          = TenantId(doc["tenantId"].get!string);
        s.name              = doc["name"].get!string;
        s.description       = doc["description"].get!string;
        s.producerSystemId  = doc["producerSystemId"].get!string;
        s.consumerSystemId  = doc["consumerSystemId"].get!string;
        s.eventType         = doc["eventType"].get!string;
        s.status            = doc["status"].get!string.to!SubscriptionStatus;
        s.formationId       = FormationId(doc["formationId"].get!string);
        s.filterExpression  = doc["filterExpression"].get!string;
        s.maxRetries        = cast(int) doc["maxRetries"].get!long;
        s.createdAt         = doc["createdAt"].get!long;
        s.updatedAt         = doc["updatedAt"].get!long;
        s.createdBy         = UserId(doc["createdBy"].get!string);
        s.updatedBy         = UserId(doc["updatedBy"].get!string);
        return s;
    }

    private Bson toBson(EventSubscription s) {
        return Bson([
            "id":               Bson(s.id.value),
            "tenantId":         Bson(s.tenantId.value),
            "name":             Bson(s.name),
            "description":      Bson(s.description),
            "producerSystemId": Bson(s.producerSystemId),
            "consumerSystemId": Bson(s.consumerSystemId),
            "eventType":        Bson(s.eventType),
            "status":           Bson(s.status.to!string),
            "formationId":      Bson(s.formationId.value),
            "filterExpression": Bson(s.filterExpression),
            "maxRetries":       Bson(cast(long) s.maxRetries),
            "createdAt":        Bson(s.createdAt),
            "updatedAt":        Bson(s.updatedAt),
            "createdBy":        Bson(s.createdBy.value),
            "updatedBy":        Bson(s.updatedBy.value)
        ]);
    }

    bool isTenantEmpty(TenantId tenantId)   { return findByTenant(tenantId).length == 0; }
    void createTenant(TenantId tenantId)     {}
    TenantId[] findAllTenants()              { return []; }
    bool existsByTenant(TenantId tenantId)   { return !isTenantEmpty(tenantId); }
    size_t countByTenant(TenantId tenantId)  { return findByTenant(tenantId).length; }
    EventSubscription[] filterByTenant(EventSubscription[] items, TenantId tenantId) {
        return items.filter!(e => e.tenantId == tenantId).array;
    }
    void removeByTenant(TenantId tenantId) @trusted {
        _collection.remove(Bson(["tenantId": Bson(tenantId.value)]));
    }

    EventSubscription[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) @trusted {
        EventSubscription[] result;
        foreach (doc; _collection.find(Bson(["tenantId": Bson(tenantId.value)])))
            result ~= fromBson(doc);
        return result;
    }

    bool existsById(TenantId tenantId, EventSubscriptionId id) @trusted {
        return !_collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)])).isNull;
    }

    EventSubscription findById(TenantId tenantId, EventSubscriptionId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
        if (doc.isNull) return EventSubscription.init;
        return fromBson(doc);
    }

    void removeById(TenantId tenantId, EventSubscriptionId id) @trusted {
        _collection.remove(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
    }

    bool existsAllById(TenantId tenantId, EventSubscriptionId[] ids) {
        import std.algorithm : all;
        return ids.all!(id => existsById(tenantId, id));
    }

    EventSubscription[] findAllById(TenantId tenantId, EventSubscriptionId[] ids) {
        EventSubscription[] result;
        foreach (id; ids) {
            auto e = findById(tenantId, id);
            if (!e.isNull) result ~= e;
        }
        return result;
    }

    void removeAllById(TenantId tenantId, EventSubscriptionId[] ids) {
        foreach (id; ids) removeById(tenantId, id);
    }

    void save(EventSubscription item) @trusted {
        auto query = Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]);
        _collection.update(query, Bson(["$set": toBson(item)]), UpdateFlags.upsert);
    }

    void saveAll(EventSubscription[] items) { foreach (i; items) save(i); }
    void update(EventSubscription item) { save(item); }
    void updateAll(EventSubscription[] items) { foreach (i; items) update(i); }
    bool exists(EventSubscription item)  { return existsById(item.tenantId, item.id); }
    void remove(EventSubscription item)  { removeById(item.tenantId, item.id); }
    void removeAll(EventSubscription[] items) { foreach (i; items) remove(i); }
    size_t countAll()                     { return findAll().length; }
    size_t indexOf(EventSubscription item){ return size_t.max; }

    EventSubscription[] findAll(size_t offset = 0, size_t limit = 0) @trusted {
        EventSubscription[] result;
        foreach (doc; _collection.find(Bson.emptyObject)) result ~= fromBson(doc);
        return result;
    }

    void removeAll() @trusted { _collection.remove(Bson.emptyObject); }

    override EventSubscription[] findByStatus(TenantId tenantId, SubscriptionStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    override EventSubscription[] findByProducerSystem(TenantId tenantId, string producerSystemId) {
        return findByTenant(tenantId).filter!(e => e.producerSystemId == producerSystemId).array;
    }

    override EventSubscription[] findByConsumerSystem(TenantId tenantId, string consumerSystemId) {
        return findByTenant(tenantId).filter!(e => e.consumerSystemId == consumerSystemId).array;
    }

    override EventSubscription[] findByFormation(TenantId tenantId, FormationId formationId) {
        return findByTenant(tenantId).filter!(e => e.formationId.value == formationId.value).array;
    }

    override bool nameExists(TenantId tenantId, string name) {
        return findByTenant(tenantId).any!(e => e.name == name);
    }
}
