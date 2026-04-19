/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.application.usecases.manage.manage_topics;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class ManageTopicsUseCase { // TODO: UIMUseCase {
    private TopicRepository repo;

    this(TopicRepository repo) {
        this.repo = repo;
    }

    Topic* getById(TopicId id) {
        return repo.findById(id);
    }

    Topic[] list() {
        return repo.findAll();
    }

    Topic[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Topic[] listByBrokerService(BrokerServiceId brokerServiceId) {
        return repo.findByBrokerService(brokerServiceId);
    }

    CommandResult create(TopicDTO dto) {
        Topic t;
        t.id = TopicId(dto.id);
        t.tenantId = dto.tenantId;
        t.brokerServiceId = BrokerServiceId(dto.brokerServiceId);
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
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(TopicDTO dto) {
        auto existing = repo.findById(TopicId(dto.id));
        if (existing is null)
            return CommandResult(false, "", "Topic not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.topicString.length > 0) existing.topicString = dto.topicString;
        if (dto.maxMessageSize.length > 0) existing.maxMessageSize = dto.maxMessageSize;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(TopicId id) {
        auto existing = repo.findById(id);
        if (existing is null)
            return CommandResult(false, "", "Topic not found");
        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
