/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.application.usecases.manage.manage_broker_services;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

class ManageBrokerServicesUseCase { // TODO: UIMUseCase {
    private BrokerServiceRepository repo;

    this(BrokerServiceRepository repo) {
        this.repo = repo;
    }

    BrokerService* getById(BrokerServiceId id) {
        return repo.findById(id);
    }

    BrokerService[] list() {
        return repo.findAll();
    }

    BrokerService[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    BrokerService[] listByStatus(BrokerServiceStatus status) {
        return repo.findByStatus(status);
    }

    CommandResult create(BrokerServiceDTO dto) {
        BrokerService bs;
        bs.id = BrokerServiceId(dto.id);
        bs.tenantId = dto.tenantId;
        bs.name = dto.name;
        bs.description = dto.description;
        bs.region = dto.region;
        bs.datacenter = dto.datacenter;
        bs.version_ = dto.version_;
        bs.maxConnections = dto.maxConnections;
        bs.maxQueueDepth = dto.maxQueueDepth;
        bs.maxMessageSize = dto.maxMessageSize;
        bs.msgVpnName = dto.msgVpnName;
        bs.createdBy = dto.createdBy;
        if (!EventMeshValidator.isValidBrokerService(bs))
            return CommandResult(false, "", "Invalid broker service data");
        repo.save(bs);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(BrokerServiceDTO dto) {
        auto existing = repo.findById(BrokerServiceId(dto.id));
        if (existing.isNull)
            return CommandResult(false, "", "Broker service not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.region.length > 0) existing.region = dto.region;
        if (dto.maxConnections.length > 0) existing.maxConnections = dto.maxConnections;
        if (dto.maxQueueDepth.length > 0) existing.maxQueueDepth = dto.maxQueueDepth;
        if (dto.maxMessageSize.length > 0) existing.maxMessageSize = dto.maxMessageSize;
        if (dto.updatedBy.length > 0) existing.updatedBy = dto.updatedBy;
        repo.update(*existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(BrokerServiceId id) {
        auto existing = repo.findById(id);
        if (existing.isNull)
            return CommandResult(false, "", "Broker service not found");
        repo.remove(id);
        return CommandResult(true, id.toString, "");
    }
}
