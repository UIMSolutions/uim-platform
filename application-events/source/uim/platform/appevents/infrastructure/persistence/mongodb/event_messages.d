/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.mongodb.event_messages;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_message;
import uim.platform.appevents.domain.repositories.event_messages;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.message_status;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter, any;
import std.array     : array;
import std.conv      : to;

@safe:

class MongoEventMessageRepository : EventMessageRepository {
    private MongoCollection _collection;

    this(MongoCollection collection) { _collection = collection; }

    private EventMessage fromBson(Bson doc) {
        EventMessage m;
        m.id             = EventMessageId(doc["id"].get!string);
        m.tenantId       = TenantId(doc["tenantId"].get!string);
        m.channelId      = EventChannelId(doc["channelId"].get!string);
        m.eventType      = doc["eventType"].get!string;
        m.payload        = doc["payload"].get!string;
        m.status         = doc["status"].get!string.to!MessageStatus;
        m.sourceSystemId = doc["sourceSystemId"].get!string;
        m.targetSystemId = doc["targetSystemId"].get!string;
        m.retryCount     = cast(int) doc["retryCount"].get!long;
        m.failedReason   = doc["failedReason"].get!string;
        m.deliveredAt    = doc["deliveredAt"].get!long;
        m.createdAt      = doc["createdAt"].get!long;
        m.createdBy      = UserId(doc["createdBy"].get!string);
        return m;
    }

    private Bson toBson(EventMessage m) {
        return Bson([
            "id":             Bson(m.id.value),
            "tenantId":       Bson(m.tenantId.value),
            "channelId":      Bson(m.channelId.value),
            "eventType":      Bson(m.eventType),
            "payload":        Bson(m.payload),
            "status":         Bson(m.status.to!string),
            "sourceSystemId": Bson(m.sourceSystemId),
            "targetSystemId": Bson(m.targetSystemId),
            "retryCount":     Bson(cast(long) m.retryCount),
            "failedReason":   Bson(m.failedReason),
            "deliveredAt":    Bson(m.deliveredAt),
            "createdAt":      Bson(m.createdAt),
            "createdBy":      Bson(m.createdBy.value)
        ]);
    }

    bool isTenantEmpty(TenantId tenantId)  { return find(tenantId).length == 0; }
    void createTenant(TenantId tenantId)    {}
    TenantId[] findAllTenants()             { return []; }
    bool existsByTenant(TenantId tenantId)  { return !isTenantEmpty(tenantId); }
    size_t countByTenant(TenantId tenantId) { return find(tenantId).length; }
    EventMessage[] filterByTenant(EventMessage[] items, TenantId tenantId) {
        return items.filter!(e => e.tenantId == tenantId).array;
    }
    void removeByTenant(TenantId tenantId) @trusted {
        _collection.remove(Bson(["tenantId": Bson(tenantId.value)]));
    }

    EventMessage[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) @trusted {
        EventMessage[] result;
        foreach (doc; _collection.find(Bson(["tenantId": Bson(tenantId.value)])))
            result ~= fromBson(doc);
        return result;
    }

    bool existsById(TenantId tenantId, EventMessageId id) @trusted {
        return !_collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)])).isNull;
    }

    EventMessage findById(TenantId tenantId, EventMessageId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
        if (doc.isNull) return EventMessage.init;
        return fromBson(doc);
    }

    void removeById(TenantId tenantId, EventMessageId id) @trusted {
        _collection.remove(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
    }

    bool existsAllById(TenantId tenantId, EventMessageId[] ids) {
        import std.algorithm : all;
        return ids.all!(id => existsById(tenantId, id));
    }

    EventMessage[] findAllById(TenantId tenantId, EventMessageId[] ids) {
        EventMessage[] result;
        foreach (id; ids) {
            auto e = find(tenantId, id);
            if (!e.isNull) result ~= e;
        }
        return result;
    }

    void removeAllById(TenantId tenantId, EventMessageId[] ids) { foreach (id; ids) removeById(tenantId, id); }

    void save(EventMessage item) @trusted {
        auto query = Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]);
        _collection.update(query, Bson(["$set": toBson(item)]), UpdateFlags.upsert);
    }

    void saveAll(EventMessage[] items) { foreach (i; items) save(i); }
    void update(EventMessage item) { save(item); }
    void updateAll(EventMessage[] items) { foreach (i; items) update(i); }
    bool exists(EventMessage item)  { return existsById(item.tenantId, item.id); }
    void remove(EventMessage item)  { removeById(item.tenantId, item.id); }
    void removeAll(EventMessage[] items) { foreach (i; items) remove(i); }
    size_t countAll()               { return findAll().length; }
    size_t indexOf(EventMessage item){ return size_t.max; }

    EventMessage[] findAll(size_t offset = 0, size_t limit = 0) @trusted {
        EventMessage[] result;
        foreach (doc; _collection.find(Bson.emptyObject)) result ~= fromBson(doc);
        return result;
    }

    void removeAll() @trusted { _collection.remove(Bson.emptyObject); }

    override EventMessage[] findByChannel(TenantId tenantId, EventChannelId channelId) {
        return find(tenantId).filter!(e => e.channelId.value == channelId.value).array;
    }

    override EventMessage[] findByStatus(TenantId tenantId, MessageStatus status) {
        return find(tenantId).filter!(e => e.status == status).array;
    }

    override EventMessage[] findBySourceSystem(TenantId tenantId, string sourceSystemId) {
        return find(tenantId).filter!(e => e.sourceSystemId == sourceSystemId).array;
    }
}
