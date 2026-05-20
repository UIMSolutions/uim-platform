/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.entities.event_message;

import uim.platform.service;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.message_status;
import std.conv : to;

@safe:

struct EventMessage {
    mixin TenantEntity!(EventMessageId);

    EventChannelId channelId;
    string eventType;
    string payload;
    MessageStatus status;
    string sourceSystemId;
    string targetSystemId;
    int retryCount = 0;
    string failedReason;
    long deliveredAt;

    Json toJson() const @safe {
        return Json.emptyObject
            .set("id",             id.value)
            .set("tenantId",       tenantId.value)
            .set("channelId",      channelId.value)
            .set("eventType",      eventType)
            .set("payload",        payload)
            .set("status",         status.to!string)
            .set("sourceSystemId", sourceSystemId)
            .set("targetSystemId", targetSystemId)
            .set("retryCount",     retryCount)
            .set("failedReason",   failedReason)
            .set("deliveredAt",    deliveredAt)
            .set("createdAt",      createdAt)
            .set("createdBy",      createdBy.value);
    }
}
