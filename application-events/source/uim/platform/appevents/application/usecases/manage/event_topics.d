/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.application.usecases.manage.event_topics;

import uim.platform.service;
import uim.platform.appevents.domain.entities.event_topic;
import uim.platform.appevents.domain.ports.repositories.event_topics;
import uim.platform.appevents.domain.valueobjects;
import uim.platform.appevents.application.dto;

@safe:

class ManageEventTopicsUseCase {
    protected IEventTopicRepository repo;

    this(IEventTopicRepository repo) {
        this.repo = repo;
    }

    EventTopic getEventTopic(TenantId tenantId, EventTopicId id) {
        return repo.findById(tenantId, id);
    }

    EventTopic[] listEventTopics(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    UsecaseResult createEventTopic(EventTopicDTO dto) {
        if (repo.nameExists(dto.tenantId, dto.name))
            return UsecaseResult(false, "", "Topic name already exists");

        auto t = EventTopic(dto.tenantId); //, dto.createdBy);
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
        return UsecaseResult(true, t.id.value, "");
    }

    UsecaseResult updateEventTopic(EventTopicDTO dto) {
        auto t = repo.findById(dto.tenantId, dto.topicId);
        if (t.isNull)
            return UsecaseResult(false, "", "Topic not found");

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
        return UsecaseResult(true, t.id.value, "");
    }

    UsecaseResult deleteEventTopic(TenantId tenantId, EventTopicId id) {
        auto t = repo.findById(tenantId, id);
        if (t.isNull)
            return UsecaseResult(false, "", "Topic not found");

        repo.remove(t);
        return UsecaseResult(true, t.id.value, "");
    }
}
