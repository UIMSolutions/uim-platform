/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.domain.entities.tid;

import uim.platform.rfc;

// mixin(ShowModule!());
@safe:

/// Transaction ID (TID) for tRFC / qRFC / bgRFC.
/// The TID is a 24-character GUID assigned to a Logical Unit of Work (LUW).
/// The RFC runtime uses it to guarantee exactly-once execution:
///   - On first receipt the TID is stored with status = open
///   - After execution the TID is committed or rolled back
///   - Duplicate TIDs are detected and the call is not re-executed
/// See: SAP tRFC documentation — "transactional sequence of calls"
struct Tid {
    TidValue     value;           /// The 24-char GUID string
    string       tenantId;
    DestinationId destinationId;
    LuwStatus    status;
    RfcCallId[]  callIds;         /// All RFC calls belonging to this LUW
    long         createdAt;
    long         updatedAt;

    bool isNull() const { return value.length == 0; }

    Json toJson() const {
        auto jCalls = Json.emptyArray;
        foreach (c; callIds) jCalls ~= Json(c);
        return Json.emptyObject
            .set("value",         value)
            .set("tenantId",      tenantId)
            .set("destinationId", destinationId)
            .set("status",        to!string(status))
            .set("callIds",       jCalls)
            .set("createdAt",     createdAt)
            .set("updatedAt",     updatedAt);
    }

    static Tid create(TenantId tenantId, DestinationId dest) {
        
        import std.uuid  : randomUUID;
        Tid t;
        t.value         = randomUUID().toString()[0 .. 24]; // 24-char TID
        t.tenantId      = tenantId;
        t.destinationId = dest;
        t.status        = LuwStatus.open;
        t.createdAt     = MonoTime.currTime.ticks;
        t.updatedAt     = t.createdAt;
        return t;
    }
}
