/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.application.usecases.manage.manage_queues;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class ManageQueuesUseCase { // TODO: UIMUseCase {
    private QueueRepository repo;

    this(QueueRepository repo) {
        this.repo = repo;
    }

    Queue* getById(QueueId id) {
        return repo.findById(id);
    }

    Queue[] list() {
        return repo.findAll();
    }

    Queue[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Queue[] listByBrokerService(BrokerServiceId brokerServiceId) {
        return repo.findByBrokerService(brokerServiceId);
    }

    CommandResult create(QueueDTO dto) {
        Queue q;
        q.id = QueueId(dto.id);
        q.tenantId = dto.tenantId;
        q.brokerServiceId = BrokerServiceId(dto.brokerServiceId);
        q.name = dto.name;
        q.description = dto.description;
        q.maxMsgSpoolUsage = dto.maxMsgSpoolUsage;
        q.maxBindCount = dto.maxBindCount;
        q.maxMsgSize = dto.maxMsgSize;
        q.maxRedeliveryCount = dto.maxRedeliveryCount;
        q.maxTtl = dto.maxTtl;
        q.deadMessageQueue = dto.deadMessageQueue;
        q.owner = dto.owner;
        q.permission = dto.permission;
        q.egressEnabled = dto.egressEnabled;
        q.ingressEnabled = dto.ingressEnabled;
        q.createdBy = dto.createdBy;
        if (!EventMeshValidator.isValidQueue(q))
            return CommandResult(false, "", "Invalid queue data");
        repo.save(q);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(QueueDTO dto) {
        auto existing = repo.findById(QueueId(dto.id));
        if (existing.isNull)
            return CommandResult(false, "", "Queue not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.maxMsgSpoolUsage.length > 0) existing.maxMsgSpoolUsage = dto.maxMsgSpoolUsage;
        if (dto.maxBindCount.length > 0) existing.maxBindCount = dto.maxBindCount;
        if (dto.maxMsgSize.length > 0) existing.maxMsgSize = dto.maxMsgSize;
        if (dto.updatedBy.length > 0) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(QueueId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Queue not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
