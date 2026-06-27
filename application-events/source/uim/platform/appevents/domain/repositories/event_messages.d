/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.repositories.event_messages;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_message;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.message_status;

@safe:

interface EventMessageRepository : ITentRepository!(EventMessage, EventMessageId) {
    EventMessage[] findByChannel(TenantId tenantId, EventChannelId channelId);
    EventMessage[] findByStatus(TenantId tenantId, MessageStatus status);
    EventMessage[] findBySourceSystem(TenantId tenantId, string sourceSystemId);
}
