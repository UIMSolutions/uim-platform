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
import uim.platform.appevents.application.dto;

@safe:

class ManageEventTopicsUseCase {
    private EventTopicRepository repo;

    this(EventTopicRepository repo) {
        this.repo = repo;
    }

    EventTopic getEventTopic(TenantId tenantId, EventTopicId id) {
        return repo.findById(tenantId, id);
    }

    EventTopic[] listEventTopics(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult createEventTopic(EventTopicDTO dto) {
        if (repo.nameExists(dto.tenantId, dto.name))
            return CommandResult(false, "", "Topic name already exists");

        EventTopic t;
        t.initEntity(dto.tenantId, dto.createdBy);
        if (!dto.topicId.isNull)
            t.id = dto.topicId;

        t.name = dto.name;
        t.namespace = dto.namespace;
        t.description = dto.description;
        t.version_ = dto.version_;
        t.category = dto.category;
        t.status = dto.status;
        t.ownerId = dto.ownerId;

        repo.save(t);
        return CommandResult(true, t.id.value, "");
    }

    CommandResult updateEventTopic(EventTopicDTO dto) {
        auto t = repo.findById(dto.tenantId, dto.topicId);
        if (t.isNull)
            return CommandResult(false, "", "Topic not found");

        t.name = dto.name;
        t.namespace = dto.namespace;
        t.description = dto.description;
        t.version_ = dto.version_;
        t.category = dto.category;
        t.status = dto.status;
        t.ownerId = dto.ownerId;
        if (!dto.updatedBy.isNull)
            t.updatedBy = dto.updatedBy;

        repo.update(t);
        return CommandResult(true, t.id.value, "");
    }

    CommandResult deleteEventTopic(TenantId tenantId, EventTopicId id) {
        auto t = repo.findById(tenantId, id);
        if (t.isNull)
            return CommandResult(false, "", "Topic not found");

        repo.remove(t);
        return CommandResult(true, t.id.value, "");
    }
}
