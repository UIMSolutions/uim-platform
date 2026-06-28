/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.application.usecases.manage.queues;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

class ManageQueuesUseCase { // TODO: UIMUseCase {
    private QueueRepository repo;

    this(QueueRepository repo) {
        this.repo = repo;
    }

    Queue getQueue(TenantId tenantId, QueueId id) {
        return repo.findById(tenantId, id);
    }

    Queue[] listQueues(TenantId tenantId) {
        return repo.find(tenantId);
    }

    Queue[] listQueues(TenantId tenantId, BrokerServiceId serviceId) {
        return repo.findByBrokerService(tenantId, serviceId);
    }

    CommandResult createQueue(QueueDTO dto) {
        Queue queue;

        queue.id = dto.queueId;
        queue.tenantId = dto.tenantId;
        queue.serviceId = dto.serviceId;
        queue.name = dto.name;
        queue.description = dto.description;
        queue.maxMsgSpoolUsage = dto.maxMsgSpoolUsage;
        queue.maxBindCount = dto.maxBindCount;
        queue.maxMsgSize = dto.maxMsgSize;
        queue.maxRedeliveryCount = dto.maxRedeliveryCount;
        queue.maxTtl = dto.maxTtl;
        queue.deadMessageQueue = dto.deadMessageQueue;
        queue.owner = dto.owner;
        queue.permission = dto.permission;
        queue.egressEnabled = dto.egressEnabled;
        queue.ingressEnabled = dto.ingressEnabled;
        queue.createdBy = dto.createdBy;
        if (!EventMeshValidator.isValidQueue(queue))
            return CommandResult(false, "", "Invalid queue data");
            
        repo.save(queue);
        return CommandResult(true, queue.id.value, "");
    }

    CommandResult updateQueue(QueueDTO dto) {
        auto queue = repo.findById(dto.tenantId, dto.queueId);
        if (queue.isNull)
            return CommandResult(false, "", "Queue not found");

        if (dto.name.length > 0) queue.name = dto.name;
        if (dto.description.length > 0) queue.description = dto.description;
        if (dto.maxMsgSpoolUsage.length > 0) queue.maxMsgSpoolUsage = dto.maxMsgSpoolUsage;
        if (dto.maxBindCount.length > 0) queue.maxBindCount = dto.maxBindCount;
        if (dto.maxMsgSize.length > 0) queue.maxMsgSize = dto.maxMsgSize;
        if (!dto.updatedBy.isNull) queue.updatedBy = dto.updatedBy;

        repo.update(queue);
        return CommandResult(true, queue.id.value, "");
    }

    CommandResult deleteQueue(TenantId tenantId, QueueId queueId) {
        auto queue = repo.findById(tenantId, queueId);
        if (queue.isNull)
            return CommandResult(false, "", "Queue not found");

        repo.remove(queue);
        return CommandResult(true, queue.id.value, "");
    }
}
