/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.application.usecases.manage.event_topics;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_topic;
import uim.platform.appevents.domain.repositories.event_topics;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.domain.enums.topic_status;
import uim.platform.appevents.application.dto;
import std.uuid : randomUUID;
import std.conv : to;

@safe:

class ManageEventTopicsUseCase {
    private EventTopicRepository _repo;

    this(EventTopicRepository repo) {
        _repo = repo;
    }

    EventTopic getEventTopic(TenantId tenantId, EventTopicId id) {
        return _repo.findById(tenantId, id);
    }

    EventTopic[] listEventTopics(TenantId tenantId) {
        return _repo.findAll(tenantId);
    }

    CommandResult createEventTopic(TenantId tenantId, EventTopicDTO dto) {
        if (_repo.nameExists(tenantId, dto.name))
            return CommandResult(false, "Topic name already exists");
        EventTopic t;
        t.id = EventTopicId(randomUUID().to!string);
        t.tenantId = tenantId;
        t.name = dto.name;
        t.namespace = dto.namespace;
        t.description = dto.description;
        t.version_ = dto.version_;
        t.category = dto.category;
        t.status = dto.status;
        t.ownerId = dto.ownerId;
        _repo.save(tenantId, t);
        return CommandResult(true, t.id.value);
    }

    CommandResult updateEventTopic(TenantId tenantId, EventTopicId id, EventTopicDTO dto) {
        auto t = _repo.findById(tenantId, id);
        if (t.id.isNull) return CommandResult(false, "Topic not found");
        t.name = dto.name;
        t.namespace = dto.namespace;
        t.description = dto.description;
        t.version_ = dto.version_;
        t.category = dto.category;
        t.status = dto.status;
        t.ownerId = dto.ownerId;
        _repo.save(tenantId, t);
        return CommandResult(true, id.value);
    }

    CommandResult deleteEventTopic(TenantId tenantId, EventTopicId id) {
        auto t = _repo.findById(tenantId, id);
        if (t.id.isNull) return CommandResult(false, "Topic not found");
        _repo.remove(tenantId, id);
        return CommandResult(true, id.value);
    }
}
