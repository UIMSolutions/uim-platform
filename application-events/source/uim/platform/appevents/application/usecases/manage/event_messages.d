/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.application.usecases.manage.event_messages;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_message;
import uim.platform.appevents.domain.repositories.event_messages;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.message_status;
import uim.platform.appevents.application.dto;

@safe:

class ManageEventMessagesUseCase {
    private EventMessageRepository repo;

    this(EventMessageRepository repo) { this.repo = repo; }

    EventMessage getEventMessage(TenantId tenantId, EventMessageId id) {
        return repo.findById(tenantId, id);
    }

    EventMessage[] listEventMessages(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    EventMessage[] listByChannel(TenantId tenantId, EventChannelId channelId) {
        return repo.findByChannel(tenantId, channelId);
    }

    CommandResult publishMessage(EventMessageDTO dto) {
        EventMessage msg;
        msg.initEntity(dto.tenantId, dto.createdBy);
        if (!dto.messageId.isNull) msg.id = dto.messageId;
        msg.channelId = dto.channelId;
        msg.eventType = dto.eventType;
        msg.payload = dto.payload;
        msg.status = MessageStatus.pending;
        msg.sourceSystemId = dto.sourceSystemId;
        msg.targetSystemId = dto.targetSystemId;
        msg.retryCount = 0;
        repo.save(msg);
        return CommandResult(true, msg.id.value, "");
    }

    CommandResult deleteEventMessage(TenantId tenantId, EventMessageId id) {
        auto msg = repo.findById(tenantId, id);
        if (msg.isNull) return CommandResult(false, "", "Message not found");
        repo.removeById(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
