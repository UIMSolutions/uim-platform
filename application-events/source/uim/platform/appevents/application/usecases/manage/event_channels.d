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
import uim.platform.appevents.application.dto;

@safe:

class ManageEventChannelsUseCase {
    private EventChannelRepository repo;

    this(EventChannelRepository repo) { this.repo = repo; }

    EventChannel getEventChannel(TenantId tenantId, EventChannelId id) {
        return repo.findById(tenantId, id);
    }

    EventChannel[] listEventChannels(TenantId tenantId) {
        return repo.find(tenantId);
    }

    CommandResult createEventChannel(EventChannelDTO dto) {
        if (repo.nameExists(dto.tenantId, dto.name))
            return CommandResult(false, "", "Channel name already exists");
        EventChannel ch;
        ch.initEntity(dto.tenantId, dto.createdBy);
        if (!dto.channelId.isNull) ch.id = dto.channelId;
        ch.name = dto.name;
        ch.topicId = dto.topicId;
        ch.channelType = dto.channelType;
        ch.endpoint = dto.endpoint;
        ch.status = dto.status;
        ch.deliveryMode = dto.deliveryMode;
        ch.maxSizeBytes = dto.maxSizeBytes;
        repo.save(ch);
        return CommandResult(true, ch.id.value, "");
    }

    CommandResult updateEventChannel(EventChannelDTO dto) {
        auto ch = repo.findById(dto.tenantId, dto.channelId);
        if (ch.isNull) return CommandResult(false, "", "Channel not found");
        ch.name = dto.name;
        ch.topicId = dto.topicId;
        ch.channelType = dto.channelType;
        ch.endpoint = dto.endpoint;
        ch.status = dto.status;
        ch.deliveryMode = dto.deliveryMode;
        ch.maxSizeBytes = dto.maxSizeBytes;
        if (!dto.updatedBy.isNull) ch.updatedBy = dto.updatedBy;
        repo.update(ch);
        return CommandResult(true, ch.id.value, "");
    }

    CommandResult deleteEventChannel(TenantId tenantId, EventChannelId id) {
        auto ch = repo.findById(tenantId, id);
        if (ch.isNull) return CommandResult(false, "", "Channel not found");

        repo.remove(ch);
        return CommandResult(true, ch.id.value, "");
    }
}
