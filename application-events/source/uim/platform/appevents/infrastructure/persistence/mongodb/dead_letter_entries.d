/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.mongodb.dead_letter_entries;

import uim.platform.service;
import uim.platform.appevents.domain.entities.dead_letter_entry;
import uim.platform.appevents.domain.repositories.dead_letter_entries;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.dead_letter_status;
import vibe.db.mongo.mongo : MongoCollection;
import std.algorithm : filter, any;
import std.array     : array;
import std.conv      : to;

@safe:

class MongoDeadLetterEntryRepository : DeadLetterEntryRepository {
    private MongoCollection _collection;

    this(MongoCollection collection) { _collection = collection; }

    private DeadLetterEntry fromBson(Bson doc) {
        DeadLetterEntry e;
        e.id                = DeadLetterEntryId(doc["id"].get!string);
        e.tenantId          = TenantId(doc["tenantId"].get!string);
        e.originalMessageId = EventMessageId(doc["originalMessageId"].get!string);
        e.channelId         = EventChannelId(doc["channelId"].get!string);
        e.errorMessage      = doc["errorMessage"].get!string;
        e.failedAt          = doc["failedAt"].get!long;
        e.retryCount        = cast(int) doc["retryCount"].get!long;
        e.status            = doc["status"].get!string.to!DeadLetterStatus;
        e.createdAt         = doc["createdAt"].get!long;
        e.createdBy         = UserId(doc["createdBy"].get!string);
        return e;
    }

    private Bson toBson(DeadLetterEntry e) {
        return Bson([
            "id":                Bson(e.id.value),
            "tenantId":          Bson(e.tenantId.value),
            "originalMessageId": Bson(e.originalMessageId.value),
            "channelId":         Bson(e.channelId.value),
            "errorMessage":      Bson(e.errorMessage),
            "failedAt":          Bson(e.failedAt),
            "retryCount":        Bson(cast(long) e.retryCount),
            "status":            Bson(e.status.to!string),
            "createdAt":         Bson(e.createdAt),
            "createdBy":         Bson(e.createdBy.value)
        ]);
    }

    bool isTenantEmpty(TenantId tenantId)  { return find(tenantId).length == 0; }
    void createTenant(TenantId tenantId)    {}
    TenantId[] findAllTenants()             { return []; }
    bool existsByTenant(TenantId tenantId)  { return !isTenantEmpty(tenantId); }
    size_t countByTenant(TenantId tenantId) { return find(tenantId).length; }
    DeadLetterEntry[] filterByTenant(DeadLetterEntry[] items, TenantId tenantId) {
        return items.filter!(e => e.tenantId == tenantId).array;
    }
    void removeByTenant(TenantId tenantId) @trusted {
        _collection.remove(Bson(["tenantId": Bson(tenantId.value)]));
    }

    DeadLetterEntry[] findByTenant(TenantId tenantId, size_t offset = 0, size_t limit = 0) @trusted {
        DeadLetterEntry[] result;
        foreach (doc; _collection.find(Bson(["tenantId": Bson(tenantId.value)])))
            result ~= fromBson(doc);
        return result;
    }

    bool existsById(TenantId tenantId, DeadLetterEntryId id) @trusted {
        return !_collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)])).isNull;
    }

    DeadLetterEntry findById(TenantId tenantId, DeadLetterEntryId id) @trusted {
        auto doc = _collection.findOne(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
        if (doc.isNull) return DeadLetterEntry.init;
        return fromBson(doc);
    }

    void removeById(TenantId tenantId, DeadLetterEntryId id) @trusted {
        _collection.remove(Bson(["tenantId": Bson(tenantId.value), "id": Bson(id.value)]));
    }

    bool existsAllById(TenantId tenantId, DeadLetterEntryId[] ids) {
        import std.algorithm : all;
        return ids.all!(id => existsById(tenantId, id));
    }

    DeadLetterEntry[] findAllById(TenantId tenantId, DeadLetterEntryId[] ids) {
        DeadLetterEntry[] result;
        foreach (id; ids) {
            auto e = findById(tenantId, id);
            if (!e.isNull) result ~= e;
        }
        return result;
    }

    void removeAllById(TenantId tenantId, DeadLetterEntryId[] ids) { foreach (id; ids) removeById(tenantId, id); }

    void save(DeadLetterEntry item) @trusted {
        auto query = Bson(["tenantId": Bson(item.tenantId.value), "id": Bson(item.id.value)]);
        _collection.update(query, Bson(["$set": toBson(item)]), UpdateFlags.upsert);
    }

    void saveAll(DeadLetterEntry[] items) { foreach (i; items) save(i); }
    void update(DeadLetterEntry item) { save(item); }
    void updateAll(DeadLetterEntry[] items) { foreach (i; items) update(i); }
    bool exists(DeadLetterEntry item)  { return existsById(item.tenantId, item.id); }
    void remove(DeadLetterEntry item)  { removeById(item.tenantId, item.id); }
    void removeAll(DeadLetterEntry[] items) { foreach (i; items) remove(i); }
    size_t countAll()                  { return findAll().length; }
    size_t indexOf(DeadLetterEntry item){ return size_t.max; }

    DeadLetterEntry[] findAll(size_t offset = 0, size_t limit = 0) @trusted {
        DeadLetterEntry[] result;
        foreach (doc; _collection.find(Bson.emptyObject)) result ~= fromBson(doc);
        return result;
    }

    void removeAll() @trusted { _collection.remove(Bson.emptyObject); }

    override DeadLetterEntry[] findByChannel(TenantId tenantId, EventChannelId channelId) {
        return find(tenantId).filter!(e => e.channelId.value == channelId.value).array;
    }

    override DeadLetterEntry[] findByStatus(TenantId tenantId, DeadLetterStatus status) {
        return find(tenantId).filter!(e => e.status == status).array;
    }

    override DeadLetterEntry[] findByOriginalMessage(TenantId tenantId, EventMessageId messageId) {
        return find(tenantId).filter!(e => e.originalMessageId.value == messageId.value).array;
    }
}
