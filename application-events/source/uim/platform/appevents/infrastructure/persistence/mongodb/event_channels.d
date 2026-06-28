/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.mongodb.event_channels;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_channel;
import uim.platform.appevents.domain.repositories.event_channels;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.channel_type;
import uim.platform.appevents.domain.enums.channel_status;
import uim.platform.appevents.domain.enums.delivery_mode;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter, any;
import std.array     : array;
import std.conv      : to;

@safe:

class MongoEventChannelRepository : EventChannelRepository {
    private MongoCollection _collection;

    this(MongoCollection collection) { _collection = collection; }

    private EventChannel fromBson(Bson doc) {
        EventChannel ch;
        ch.id           = EventChannelId(doc["id"].get!string);
        ch.tenantId     = TenantId(doc["tenantId"].get!string);
        ch.name         = doc["name"].get!string;
        ch.topicId      = EventTopicId(doc["topicId"].get!string);
        ch.channelType  = doc["channelType"].get!string.to!ChannelType;
        ch.endpoint     = doc["endpoint"].get!string;
        ch.status       = doc["status"].get!string.to!ChannelStatus;
        ch.deliveryMode = doc["deliveryMode"].get!string.to!DeliveryMode;
        ch.maxSizeBytes = doc["maxSizeBytes"].get!long;
        ch.createdAt    = doc["createdAt"].get!long;
        ch.updatedAt    = doc["updatedAt"].get!long;
        ch.createdBy    = UserId(doc["createdBy"].get!string);
        ch.updatedBy    = UserId(doc["updatedBy"].get!string);
        return ch;
    }

    private Bson toBson(EventChannel ch) {
        return Bson([
            "id":           Bson(ch.id.value),
            "tenantId":     Bson(ch.tenantId.value),
            "name":         Bson(ch.name),
            "topicId":      Bson(ch.topicId.value),
            "channelType":  Bson(ch.channelType.to!string),
            "endpoint":     Bson(ch.endpoint),
            "status":       Bson(ch.status.to!string),
            "deliveryMode": Bson(ch.deliveryMode.to!string),
            "maxSizeBytes": Bson(ch.maxSizeBytes),
            "createdAt":    Bson(ch.createdAt),
            "updatedAt":    Bson(ch.updatedAt),
            "createdBy":    Bson(ch.createdBy.value),
            "updatedBy":    Bson(ch.updatedBy.value)
        ]);
    }

    bool isTenantEmpty(TenantId tenantId)  { return find(tenantId).length == 0; }
    void createTenant(TenantId tenantId)    {}
    TenantId[] findAllTenants()             { return []; }
    bool existsByTenant(TenantId tenantId)  { return !isTenantEmpty(tenantId); }
    size_t countByTenant(TenantId tenantId) { return find(tenantId).length; }
    EventChannel[] filterByTenant(EventChannel[] items, TenantId tenantId) {
        return items.filter!(e => e.tenantId == tenantId).array;
    }
    void removeByTenant(TenantId tenantId) @trusted {
        _collection.remove(Bson(["tenantId": Bson(tenantId.value)]));
    }

    EventChannel[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) @trusted {
        EventChannel[] result;
        foreach (doc; _collection.find(Bson(["tenantId": Bson(tenantId.value)])))
            result ~= fromBson(doc);
        return result;
    }

    bool existsById(TenantId tenantId, EventChannelId id) @trusted {
        return !_collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)])).isNull;
    }

    EventChannel findById(TenantId tenantId, EventChannelId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
        if (doc.isNull) return EventChannel.init;
        return fromBson(doc);
    }

    void removeById(TenantId tenantId, EventChannelId id) @trusted {
        _collection.remove(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
    }

    bool existsAllById(TenantId tenantId, EventChannelId[] ids) {
        import std.algorithm : all;
        return ids.all!(id => existsById(tenantId, id));
    }

    EventChannel[] findAllById(TenantId tenantId, EventChannelId[] ids) {
        EventChannel[] result;
        foreach (id; ids) {
            auto e = findById(tenantId, id);
            if (!e.isNull) result ~= e;
        }
        return result;
    }

    void removeAllById(TenantId tenantId, EventChannelId[] ids) { foreach (id; ids) removeById(tenantId, id); }

    void save(EventChannel item) @trusted {
        auto query = Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]);
        _collection.update(query, Bson(["$set": toBson(item)]), UpdateFlags.upsert);
    }

    void saveAll(EventChannel[] items) { foreach (i; items) save(i); }
    void update(EventChannel item) { save(item); }
    void updateAll(EventChannel[] items) { foreach (i; items) update(i); }
    bool exists(EventChannel item)  { return existsById(item.tenantId, item.id); }
    void remove(EventChannel item)  { removeById(item.tenantId, item.id); }
    void removeAll(EventChannel[] items) { foreach (i; items) remove(i); }
    size_t countAll()               { return findAll().length; }
    size_t indexOf(EventChannel item){ return size_t.max; }

    EventChannel[] findAll(size_t offset = 0, size_t limit = 0) @trusted {
        EventChannel[] result;
        foreach (doc; _collection.find(Bson.emptyObject)) result ~= fromBson(doc);
        return result;
    }

    void removeAll() @trusted { _collection.remove(Bson.emptyObject); }

    override EventChannel[] findByTopic(TenantId tenantId, EventTopicId topicId) {
        return find(tenantId).filter!(e => e.topicId.value == topicId.value).array;
    }

    override EventChannel[] findByStatus(TenantId tenantId, ChannelStatus status) {
        return find(tenantId).filter!(e => e.status == status).array;
    }

    override bool nameExists(TenantId tenantId, string name) {
        return find(tenantId).any!(e => e.name == name);
    }
}
