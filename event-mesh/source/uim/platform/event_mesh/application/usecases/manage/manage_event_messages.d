/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.application.usecases.manage.manage_event_messages;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class ManageEventMessagesUseCase { // TODO: UIMUseCase {
    private EventMessageRepository repo;

    this(EventMessageRepository repo) {
        this.repo = repo;
    }

    EventMessage* getById(EventMessageId id) {
        return repo.findById(id);
    }

    EventMessage[] list() {
        return repo.findAll();
    }

    EventMessage[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    EventMessage[] listByTopic(TopicId topicId) {
        return repo.findByTopic(topicId);
    }

    EventMessage[] listByQueue(QueueId queueId) {
        return repo.findByQueue(queueId);
    }

    CommandResult publish(EventMessageDTO dto) {
        EventMessage m;
        m.id = EventMessageId(dto.id);
        m.tenantId = dto.tenantId;
        m.brokerServiceId = BrokerServiceId(dto.brokerServiceId);
        m.topicId = TopicId(dto.topicId);
        m.queueId = QueueId(dto.queueId);
        m.publisherId = EventApplicationId(dto.publisherId);
        m.correlationId = dto.correlationId;
        m.contentType = dto.contentType;
        m.payload = dto.payload;
        m.topicString = dto.topicString;
        m.replyTo = dto.replyTo;
        m.timeToLive = dto.timeToLive;
        m.createdBy = dto.createdBy;
        if (!EventMeshValidator.isValidEventMessage(m))
            return CommandResult(false, "", "Invalid event message data");
        repo.save(m);
        return CommandResult(true, dto.id, "");
    }

    CommandResult acknowledge(EventMessageId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Event message not found");
        existing.status = MessageStatus.acknowledged;
        repo.update(existing);
        return CommandResult(true, id.value, "");
    }

    CommandResult remove(EventMessageId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Event message not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
