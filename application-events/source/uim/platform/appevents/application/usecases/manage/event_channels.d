/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.application.usecases.manage.event_channels;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_channel;
import uim.platform.appevents.domain.repositories.event_channels;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.channel_status;
import uim.platform.appevents.application.dto;
import std.uuid : randomUUID;
import std.conv : to;

@safe:

class ManageEventChannelsUseCase {
    private EventChannelRepository _repo;

    this(EventChannelRepository repo) {
        _repo = repo;
    }

    EventChannel getEventChannel(TenantId tenantId, EventChannelId id) {
        return _repo.findById(tenantId, id);
    }

    EventChannel[] listEventChannels(TenantId tenantId) {
        return _repo.findAll(tenantId);
    }

    CommandResult createEventChannel(TenantId tenantId, EventChannelDTO dto) {
        if (_repo.nameExists(tenantId, dto.name))
            return CommandResult(false, "Channel name already exists");
        EventChannel ch;
        ch.id = EventChannelId(randomUUID().to!string);
        ch.tenantId = tenantId;
        ch.name = dto.name;
        ch.topicId = EventTopicId(dto.topicId);
        ch.channelType = dto.channelType;
        ch.endpoint = dto.endpoint;
        ch.status = dto.status;
        ch.deliveryMode = dto.deliveryMode;
        ch.maxSizeBytes = dto.maxSizeBytes;
        _repo.save(tenantId, ch);
        return CommandResult(true, ch.id.value);
    }

    CommandResult updateEventChannel(TenantId tenantId, EventChannelId id, EventChannelDTO dto) {
        auto ch = _repo.findById(tenantId, id);
        if (ch.id.isNull) return CommandResult(false, "Channel not found");
        ch.name = dto.name;
        ch.topicId = EventTopicId(dto.topicId);
        ch.channelType = dto.channelType;
        ch.endpoint = dto.endpoint;
        ch.status = dto.status;
        ch.deliveryMode = dto.deliveryMode;
        ch.maxSizeBytes = dto.maxSizeBytes;
        _repo.save(tenantId, ch);
        return CommandResult(true, id.value);
    }

    CommandResult deleteEventChannel(TenantId tenantId, EventChannelId id) {
        auto ch = _repo.findById(tenantId, id);
        if (ch.id.isNull) return CommandResult(false, "Channel not found");
        _repo.remove(tenantId, id);
        return CommandResult(true, id.value);
    }
}
