/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.application.usecases.manage.topics;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

class ManageTopicsUseCase { // TODO: UIMUseCase {
    private TopicRepository repo;

    this(TopicRepository repo) {
        this.repo = repo;
    }

    Topic getTopic(TenantId tenantId, TopicId topicId) {
        return repo.findById(tenantId, topicId);
    }

    Topic[] listTopics(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Topic[] listTopics(TenantId tenantId, BrokerServiceId serviceId) {
        return repo.findByBrokerService(tenantId, serviceId);
    }

    CommandResult createTopic(TopicDTO dto) {
        Topic t;
        t.id = dto.topicId;
        t.tenantId = dto.tenantId;
        // TODO: t.serviceId = dto.serviceId;
        t.name = dto.name;
        t.description = dto.description;
        t.topicString = dto.topicString;
        t.maxMessageSize = dto.maxMessageSize;
        t.publishEnabled = dto.publishEnabled;
        t.subscribeEnabled = dto.subscribeEnabled;
        t.createdBy = dto.createdBy;
        if (!EventMeshValidator.isValidTopic(t))
            return CommandResult(false, "", "Invalid topic data");

        repo.save(t);
        return CommandResult(true, dto.topicId.value, "");
    }

    CommandResult updateTopic(TopicDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.topicId);
        if (existing.isNull)
            return CommandResult(false, "", "Topic not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.topicString.length > 0) existing.topicString = dto.topicString;
        if (dto.maxMessageSize.length > 0) existing.maxMessageSize = dto.maxMessageSize;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.topicId.value, "");
    }

    CommandResult deleteTopic(TenantId tenantId, TopicId topicId) {
        auto entity = repo.findById(tenantId, topicId);
        if (entity.isNull)
            return CommandResult(false, "", "Topic not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
