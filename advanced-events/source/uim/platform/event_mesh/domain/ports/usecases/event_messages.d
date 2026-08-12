/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.domain.ports.usecases.event_messages;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

interface IManageEventMessagesUseCase { 

    EventMessage getMessage(TenantId tenantId, EventMessageId id);
    EventMessage[] listMessages(TenantId tenantId);
    EventMessage[] listMessages(TenantId tenantId, TopicId topicId);
    EventMessage[] listMessages(TenantId tenantId, QueueId queueId);
    CommandResult publishMessage(EventMessageDTO dto);
    CommandResult acknowledgeMessage(TenantId tenantId, EventMessageId messageId);
    CommandResult deleteMessage(TenantId tenantId, EventMessageId messageId);
}

