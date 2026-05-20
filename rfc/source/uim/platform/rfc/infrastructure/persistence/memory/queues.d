/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.infrastructure.persistence.memory.queues;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

class MemoryRfcQueueRepository : RfcQueueRepository {

    private RfcQueueEntry[string] _store;

    private static string _key(string tenantId, string id) {
        return tenantId ~ "|" ~ id;
    }

    override RfcQueueEntry findById(string tenantId, string id) {
        auto key = _key(tenantId, id);
        if (key !in _store) return RfcQueueEntry.init;
        return _store[key];
    }

    override RfcQueueEntry[] findByQueue(string tenantId, QueueName queueName) {
        RfcQueueEntry[] result;
        foreach (kv; _store.byKeyValue())
            if (kv.value.tenantId == tenantId && kv.value.queueName == queueName)
                result ~= _copy(kv.value);
        return result;
    }

    override RfcQueueEntry[] findByTid(string tenantId, TidValue tid) {
        RfcQueueEntry[] result;
        foreach (kv; _store.byKeyValue())
            if (kv.value.tenantId == tenantId && kv.value.tid == tid)
                result ~= _copy(kv.value);
        return result;
    }

    override RfcQueueEntry[] findPending(string tenantId, QueueName queueName) {
        RfcQueueEntry[] result;
        foreach (kv; _store.byKeyValue())
            if (kv.value.tenantId == tenantId && kv.value.queueName == queueName
                && kv.value.status == RfcStatus.queued)
                result ~= _copy(kv.value);
        return result;
    }

    override bool save(RfcQueueEntry entry) {
        auto key = _key(entry.tenantId, entry.id);
        if (key in _store) return false;
        _store[key] = entry;
        return true;
    }

    override bool update(RfcQueueEntry entry) {
        auto key = _key(entry.tenantId, entry.id);
        if (key !in _store) return false;
        _store[key] = entry;
        return true;
    }

    override bool remove(string tenantId, string id) {
        auto key = _key(tenantId, id);
        if (key !in _store) return false;
        _store.remove(key);
        return true;
    }

    override size_t countByQueue(string tenantId, QueueName queueName) {
        size_t n = 0;
        foreach (kv; _store.byKeyValue())
            if (kv.value.tenantId == tenantId && kv.value.queueName == queueName) n++;
        return n;
    }

private:
    static RfcQueueEntry _copy(ref const RfcQueueEntry src) {
        RfcQueueEntry e;
        e.id          = src.id;
        e.tenantId    = src.tenantId;
        e.queueName   = src.queueName;
        e.direction   = src.direction;
        e.tid         = src.tid;
        e.callId      = src.callId;
        e.sequenceNr  = src.sequenceNr;
        e.status      = src.status;
        e.enqueuedAt  = src.enqueuedAt;
        e.processedAt = src.processedAt;
        return e;
    }
}
