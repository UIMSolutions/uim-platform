/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.usecases.manage.queues;

import uim.platform.events;

mixin(ShowModule!());

@safe:

class ManageQueuesUseCase {
    private QueueRepository repo;

    this(QueueRepository repo) { this.repo = repo; }

    Queue getQueue(TenantId tenantId, QueueId id) { return repo.findById(tenantId, id); }
    Queue[] listQueues(TenantId tenantId) { return repo.findByTenant(tenantId); }
    Queue[] listByService(TenantId tenantId, MessagingServiceId serviceId) { return repo.findByService(tenantId, serviceId); }

    CommandResult createQueue(QueueDTO dto) {
        Queue q;
        q.id = dto.queueId;
        q.tenantId = dto.tenantId;
        q.serviceId = dto.serviceId;
        q.name = dto.name;
        q.description = dto.description;
        q.maxMessageSizeBytes = dto.maxMessageSizeBytes;
        q.maxQueueSizeBytes = dto.maxQueueSizeBytes;
        q.maxConsumers = dto.maxConsumers;
        q.deadLetterQueue = dto.deadLetterQueue;
        q.discardMessages = dto.discardMessages;
        q.maxRedeliveryCount = dto.maxRedeliveryCount;
        q.messageExpiryTimer = dto.messageExpiryTimer;
        q.owner = dto.owner;
        q.permission = dto.permission;
        q.egressEnabled = dto.egressEnabled;
        q.ingressEnabled = dto.ingressEnabled;
        q.createdBy = dto.createdBy;
        if (!EventsValidator.isValidQueue(q))
            return CommandResult(false, "", "Invalid queue data");
        repo.save(q);
        return CommandResult(true, q.id.value, "");
    }

    CommandResult updateQueue(QueueDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.queueId);
        if (existing.isNull) return CommandResult(false, "", "Queue not found");
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.maxMessageSizeBytes.length > 0) existing.maxMessageSizeBytes = dto.maxMessageSizeBytes;
        if (dto.maxQueueSizeBytes.length > 0) existing.maxQueueSizeBytes = dto.maxQueueSizeBytes;
        if (dto.maxConsumers.length > 0) existing.maxConsumers = dto.maxConsumers;
        if (dto.deadLetterQueue.length > 0) existing.deadLetterQueue = dto.deadLetterQueue;
        if (dto.maxRedeliveryCount.length > 0) existing.maxRedeliveryCount = dto.maxRedeliveryCount;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteQueue(TenantId tenantId, QueueId id) {
        auto q = repo.findById(tenantId, id);
        if (q.isNull) return CommandResult(false, "", "Queue not found");
        repo.remove(q);
        return CommandResult(true, q.id.value, "");
    }
}

///
unittest {
    auto repo = new QueueRepository();
    auto usecase = new ManageQueuesUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test create
    QueueDTO createDto;
    createDto.tenantId = tenantId;
    createDto.queueId = QueueId("queue-1");
    createDto.name = "Test Queue";
    auto createResult = usecase.createQueue(createDto);
    assert(createResult.success, createResult.message);

    // Test list
    auto items = usecase.listQueues(tenantId);
    assert(items.length == 1);

    // Test get
    auto item = usecase.getQueue(tenantId, QueueId("queue-1"));
    assert(!item.isNull);

    // Test update
    QueueDTO updateDto;
    updateDto.tenantId = tenantId;
    updateDto.queueId = QueueId("queue-1");
    updateDto.name = "Updated Queue";
    auto updateResult = usecase.updateQueue(updateDto);
    assert(updateResult.success, updateResult.message);

    // Test delete
    auto deleteResult = usecase.deleteQueue(tenantId, QueueId("queue-1"));
    assert(deleteResult.success, deleteResult.message);
    assert(usecase.listQueues(tenantId).length == 0);

}
