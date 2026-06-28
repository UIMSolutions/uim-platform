/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.application.usecases.manage.event_messages;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

class ManageEventMessagesUseCase { // TODO: UIMUseCase {
    private EventMessageRepository repo;

    this(EventMessageRepository repo) {
        this.repo = repo;
    }

    EventMessage getMessage(TenantId tenantId, EventMessageId id) {
        return repo.find(tenantId, id);
    }

    EventMessage[] listMessages(TenantId tenantId) {
        return repo.find(tenantId);
    }

    EventMessage[] listMessages(TenantId tenantId, TopicId topicId) {
        return repo.findByTopic(tenantId, topicId);
    }

    EventMessage[] listMessages(TenantId tenantId, QueueId queueId) {
        return repo.findByQueue(tenantId, queueId);
    }

    CommandResult publishMessage(EventMessageDTO dto) {
        EventMessage message;

        message.id = dto.messageId;
        message.tenantId = dto.tenantId;
        message.serviceId = dto.serviceId;
        message.topicId = dto.topicId;
        message.queueId = dto.queueId;
        // TODO: message.publisherId = dto.publisherId;
        message.correlationId = dto.correlationId;
        message.contentType = dto.contentType;
        message.payload = dto.payload;
        message.topicString = dto.topicString;
        message.replyTo = dto.replyTo;
        message.timeToLive = dto.timeToLive;
        message.createdBy = dto.createdBy;
        if (!EventMeshValidator.isValidEventMessage(message))
            return CommandResult(false, "", "Invalid event message data");

        repo.save(message);
        return CommandResult(true, message.id.value, "");
    }

    CommandResult acknowledgeMessage(TenantId tenantId, EventMessageId messageId) {
        auto message = repo.findById(tenantId, messageId);
        if (message.isNull)
            return CommandResult(false, "", "Event message not found");

        message.status = MessageStatus.acknowledged;

        repo.update(message);
        return CommandResult(true, message.id.value, "");
    }

    CommandResult deleteMessage(TenantId tenantId, EventMessageId messageId) {
        auto message = repo.findById(tenantId, messageId);
        if (message.isNull)
            return CommandResult(false, "", "Event message not found");

        repo.remove(message);
        return CommandResult(true, message.id.value, "");
    }
}
