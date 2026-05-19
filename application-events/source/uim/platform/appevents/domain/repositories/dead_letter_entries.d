/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.repositories.dead_letter_entries;

import uim.platform.service;
import uim.platform.appevents.domain.entities.dead_letter_entry;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.dead_letter_status;

@safe:

interface DeadLetterEntryRepository : ITenantRepository!(DeadLetterEntry, DeadLetterEntryId) {
    DeadLetterEntry[] findByChannel(TenantId tenantId, EventChannelId channelId);
    DeadLetterEntry[] findByStatus(TenantId tenantId, DeadLetterStatus status);
    DeadLetterEntry[] findByOriginalMessage(TenantId tenantId, EventMessageId messageId);
}
