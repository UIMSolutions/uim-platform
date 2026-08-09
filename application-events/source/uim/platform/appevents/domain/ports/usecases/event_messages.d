/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.ports.usecases.event_messages;

import uim.platform.appevents;

mixin(ShowModule!());

@safe:

interface IManageEventMessagesUseCase {

    EventMessage getEventMessage(TenantId tenantId, EventMessageId id);
    EventMessage[] listEventMessages(TenantId tenantId);
    EventMessage[] listByChannel(TenantId tenantId, EventChannelId channelId);
    CommandResult publishMessage(EventMessageDTO dto);
    CommandResult deleteEventMessage(TenantId tenantId, EventMessageId id);

}
