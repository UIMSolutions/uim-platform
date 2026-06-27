/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.memory.event_messages;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_message;
import uim.platform.appevents.domain.repositories.event_messages;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.message_status;
import std.algorithm : filter;
import std.array : array;

@safe:

class MemoryEventMessageRepository
    : TentRepository!(EventMessage, EventMessageId)
    , EventMessageRepository
{
    override EventMessage[] findByChannel(TenantId tenantId, EventChannelId channelId) {
        return findByTenant(tenantId).filter!(m => m.channelId.value == channelId.value).array;
    }

    override EventMessage[] findByStatus(TenantId tenantId, MessageStatus status) {
        return findByTenant(tenantId).filter!(m => m.status == status).array;
    }

    override EventMessage[] findBySourceSystem(TenantId tenantId, string sourceSystemId) {
        return findByTenant(tenantId).filter!(m => m.sourceSystemId == sourceSystemId).array;
    }
}
