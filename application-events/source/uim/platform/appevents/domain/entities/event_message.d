/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.entities.event_message;

import uim.platform.service;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.message_status;
import vibe.data.json;
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
    long createdAt;

    Json toJson() const @safe {
        auto j = Json.emptyObject;
        j["id"]             = id.value;
        j["tenantId"]       = tenantId.value;
        j["channelId"]      = channelId.value;
        j["eventType"]      = eventType;
        j["payload"]        = payload;
        j["status"]         = status.to!string;
        j["sourceSystemId"] = sourceSystemId;
        j["targetSystemId"] = targetSystemId;
        j["retryCount"]     = retryCount;
        j["failedReason"]   = failedReason;
        j["deliveredAt"]    = deliveredAt;
        j["createdAt"]      = createdAt;
        return j;
    }
}
