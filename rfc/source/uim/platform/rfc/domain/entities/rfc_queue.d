/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.domain.entities.rfc_queue;

import uim.platform.rfc;

mixin(ShowModule!());
@safe:

/// A queue entry in the qRFC / bgRFC outbound or inbound queue.
/// qRFC extends tRFC by serialising multiple LUWs within a named queue
/// so that LUWs are executed in the order they were enqueued.
/// See: SAP documentation — "Queued RFC (qRFC)" section.
struct RfcQueueEntry {
    string        id;
    string        tenantId;
    QueueName     queueName;
    QueueDirection direction;  /// outbound | inbound
    TidValue      tid;         /// TID of the LUW this entry belongs to
    RfcCallId     callId;
    int           sequenceNr; /// Position within the queue (0-based)
    RfcStatus     status;
    long          enqueuedAt;
    long          processedAt;

    bool isNull() const { return id.length == 0; }

    Json toJson() const {
        return Json.emptyObject
            .set("id",          id)
            .set("tenantId",    tenantId)
            .set("queueName",   queueName)
            .set("direction",   to!string(direction))
            .set("tid",         tid)
            .set("callId",      callId)
            .set("sequenceNr",  cast(long) sequenceNr)
            .set("status",      to!string(status))
            .set("enqueuedAt",  enqueuedAt)
            .set("processedAt", processedAt);
    }

    static RfcQueueEntry create(TenantId tenantId, QueueName queueName, QueueDirection dir,
                                TidValue tid, RfcCallId callId, int seq) {
        
        import std.uuid  : randomUUID;
        RfcQueueEntry e;
        e.id          = randomUUID().toString();
        e.tenantId    = tenantId;
        e.queueName   = queueName;
        e.direction   = dir;
        e.tid         = tid;
        e.callId      = callId;
        e.sequenceNr  = seq;
        e.status      = RfcStatus.queued;
        e.enqueuedAt  = MonoTime.currTime.ticks;
        return e;
    }
}
