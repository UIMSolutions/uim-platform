/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.entities.dead_letter_entry;

import uim.platform.service;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.dead_letter_status;
import std.conv : to;

@safe:

struct DeadLetterEntry {
    mixin TenantEntity!(DeadLetterEntryId);

    EventMessageId originalMessageId;
    EventChannelId channelId;
    string errorMessage;
    long failedAt;
    int retryCount = 0;
    DeadLetterStatus status;

    Json toJson() const @safe {
        return Json.emptyObject
            .set("id",                id.value)
            .set("tenantId",          tenantId.value)
            .set("originalMessageId", originalMessageId.value)
            .set("channelId",         channelId.value)
            .set("errorMessage",      errorMessage)
            .set("failedAt",          failedAt)
            .set("retryCount",        retryCount)
            .set("status",            status.to!string)
            .set("createdAt",         createdAt)
            .set("createdBy",         createdBy.value);
    }
}
