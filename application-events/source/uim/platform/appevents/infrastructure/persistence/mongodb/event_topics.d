/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.mongodb.event_topics;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_topic;
import uim.platform.appevents.domain.repositories.event_topics;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.topic_status;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter, any;
import std.array     : array;
import std.conv      : to;

@safe:

class MongoEventTopicRepository : EventTopicRepository {
    private MongoCollection _collection;

    this(MongoCollection collection) { _collection = collection; }

    private EventTopic fromBson(Bson doc) {
        EventTopic t;
        t.id          = EventTopicId(doc["id"].get!string);
        t.tenantId    = TenantId(doc["tenantId"].get!string);
        t.name        = doc["name"].get!string;
        t.namespace   = doc["namespace"].get!string;
        t.description = doc["description"].get!string;
        t.version_    = doc["version"].get!string;
        t.category    = doc["category"].get!string;
        t.status      = doc["status"].get!string.to!TopicStatus;
        t.ownerId     = doc["ownerId"].get!string;
        t.createdAt   = doc["createdAt"].get!long;
        t.updatedAt   = doc["updatedAt"].get!long;
        t.createdBy   = UserId(doc["createdBy"].get!string);
        t.updatedBy   = UserId(doc["updatedBy"].get!string);
        return t;
    }

    private Bson toBson(EventTopic t) {
        return Bson([
            "id":          Bson(t.id.value),
            "tenantId":    Bson(t.tenantId.value),
            "name":        Bson(t.name),
            "namespace":   Bson(t.namespace),
            "description": Bson(t.description),
            "version":     Bson(t.version_),
            "category":    Bson(t.category),
            "status":      Bson(t.status.to!string),
            "ownerId":     Bson(t.ownerId),
            "createdAt":   Bson(t.createdAt),
            "updatedAt":   Bson(t.updatedAt),
            "createdBy":   Bson(t.createdBy.value),
            "updatedBy":   Bson(t.updatedBy.value)
        ]);
    }

    bool isTenantEmpty(TenantId tenantId)  { return find(tenantId).length == 0; }
    void createTenant(TenantId tenantId)    {}
    TenantId[] findAllTenants()             { return []; }
    bool existsByTenant(TenantId tenantId)  { return !isTenantEmpty(tenantId); }
    size_t countByTenant(TenantId tenantId) { return find(tenantId).length; }
    EventTopic[] filterByTenant(EventTopic[] items, TenantId tenantId) {
        return items.filter!(e => e.tenantId == tenantId).array;
    }
    void removeByTenant(TenantId tenantId) @trusted {
        _collection.remove(Bson(["tenantId": Bson(tenantId.value)]));
    }

    EventTopic[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) @trusted {
        EventTopic[] result;
        foreach (doc; _collection.find(Bson(["tenantId": Bson(tenantId.value)])))
            result ~= fromBson(doc);
        return result;
    }

    bool existsById(TenantId tenantId, EventTopicId id) @trusted {
        return !_collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)])).isNull;
    }

    EventTopic findById(TenantId tenantId, EventTopicId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
        if (doc.isNull) return EventTopic.init;
        return fromBson(doc);
    }

    void removeById(TenantId tenantId, EventTopicId id) @trusted {
        _collection.remove(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
    }

    bool existsAllById(TenantId tenantId, EventTopicId[] ids) {
        import std.algorithm : all;
        return ids.all!(id => existsById(tenantId, id));
    }

    EventTopic[] findAllById(TenantId tenantId, EventTopicId[] ids) {
        EventTopic[] result;
        foreach (id; ids) {
            auto e = findById(tenantId, id);
            if (!e.isNull) result ~= e;
        }
        return result;
    }

    void removeAllById(TenantId tenantId, EventTopicId[] ids) { foreach (id; ids) removeById(tenantId, id); }

    void save(EventTopic item) @trusted {
        auto query = Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]);
        _collection.update(query, Bson(["$set": toBson(item)]), UpdateFlags.upsert);
    }

    void saveAll(EventTopic[] items) { foreach (i; items) save(i); }
    void update(EventTopic item) { save(item); }
    void updateAll(EventTopic[] items) { foreach (i; items) update(i); }
    bool exists(EventTopic item)  { return existsById(item.tenantId, item.id); }
    void remove(EventTopic item)  { removeById(item.tenantId, item.id); }
    void removeAll(EventTopic[] items) { foreach (i; items) remove(i); }
    size_t countAll()              { return findAll().length; }
    size_t indexOf(EventTopic item){ return size_t.max; }

    EventTopic[] findAll(size_t offset = 0, size_t limit = 0) @trusted {
        EventTopic[] result;
        foreach (doc; _collection.find(Bson.emptyObject)) result ~= fromBson(doc);
        return result;
    }

    void removeAll() @trusted { _collection.remove(Bson.emptyObject); }

    override EventTopic[] findByStatus(TenantId tenantId, TopicStatus status) {
        return find(tenantId).filter!(e => e.status == status).array;
    }

    override EventTopic[] findByNamespace(TenantId tenantId, string namespace) {
        return find(tenantId).filter!(e => e.namespace == namespace).array;
    }

    override bool nameExists(TenantId tenantId, string name) {
        return find(tenantId).any!(e => e.name == name);
    }
}
