/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.infrastructure.persistence.memory.dead_letter_entries;

import uim.platform.service;
import uim.platform.appevents.domain.entities.dead_letter_entry;
import uim.platform.appevents.domain.repositories.dead_letter_entries;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.dead_letter_status;
import std.algorithm : filter;
import std.array : array;

@safe:

class MemoryDeadLetterEntryRepository
    : TenantRepository!(DeadLetterEntry, DeadLetterEntryId)
    , DeadLetterEntryRepository
{
    override DeadLetterEntry[] findByChannel(TenantId tenantId, EventChannelId channelId) {
        return findByTenant(tenantId).filter!(e => e.channelId.value == channelId.value).array;
    }

    override DeadLetterEntry[] findByStatus(TenantId tenantId, DeadLetterStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    override DeadLetterEntry[] findByOriginalMessage(TenantId tenantId, EventMessageId messageId) {
        return findByTenant(tenantId).filter!(e => e.originalMessageId.value == messageId.value).array;
    }
}
