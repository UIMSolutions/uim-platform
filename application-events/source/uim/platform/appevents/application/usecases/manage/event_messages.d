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
import std.datetime.systime : Clock;
import std.uuid : randomUUID;
import std.conv : to;

@safe:

class ManageEventMessagesUseCase {
    private EventMessageRepository _repo;

    this(EventMessageRepository repo) {
        _repo = repo;
    }

    EventMessage getEventMessage(TenantId tenantId, EventMessageId id) {
        return _repo.findById(tenantId, id);
    }

    EventMessage[] listEventMessages(TenantId tenantId) {
        return _repo.findAll(tenantId);
    }

    EventMessage[] listByChannel(TenantId tenantId, EventChannelId channelId) {
        return _repo.findByChannel(tenantId, channelId);
    }

    CommandResult publishMessage(TenantId tenantId, EventMessageDTO dto) {
        EventMessage msg;
        msg.id = EventMessageId(randomUUID().to!string);
        msg.tenantId = tenantId;
        msg.channelId = EventChannelId(dto.channelId);
        msg.eventType = dto.eventType;
        msg.payload = dto.payload;
        msg.status = MessageStatus.pending;
        msg.sourceSystemId = dto.sourceSystemId;
        msg.targetSystemId = dto.targetSystemId;
        msg.retryCount = 0;
        msg.createdAt = Clock.currTime().toUnixTime();
        _repo.save(tenantId, msg);
        return CommandResult(true, msg.id.value);
    }

    CommandResult deleteEventMessage(TenantId tenantId, EventMessageId id) {
        auto msg = _repo.findById(tenantId, id);
        if (msg.id.isNull) return CommandResult(false, "Message not found");
        _repo.remove(tenantId, id);
        return CommandResult(true, id.value);
    }
}
