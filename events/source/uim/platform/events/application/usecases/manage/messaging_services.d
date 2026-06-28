/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.application.usecases.manage.messaging_services;

import uim.platform.events;

// mixin(ShowModule!());

@safe:

class ManageMessagingServicesUseCase {
    private MessagingServiceRepository repo;

    this(MessagingServiceRepository repo) { this.repo = repo; }

    MessagingService getService(TenantId tenantId, MessagingServiceId id) {
        return repo.findById(tenantId, id);
    }

    MessagingService[] listServices(TenantId tenantId) {
        return repo.find(tenantId);
    }

    MessagingService[] listByStatus(TenantId tenantId, MessagingServiceStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    MessagingService[] listByNamespace(TenantId tenantId, string namespace) {
        return repo.findByNamespace(tenantId, namespace);
    }

    CommandResult createService(MessagingServiceDTO dto) {
        MessagingService s;
        s.id = dto.serviceId;
        s.tenantId = dto.tenantId;
        s.name = dto.name;
        s.description = dto.description;
        s.namespace = dto.namespace;
        s.region = dto.region;
        s.datacenter = dto.datacenter;
        s.version_ = dto.version_;
        s.maxConnections = dto.maxConnections;
        s.maxQueues = dto.maxQueues;
        s.maxQueueDepth = dto.maxQueueDepth;
        s.maxMessageSize = dto.maxMessageSize;
        s.createdBy = dto.createdBy;
        if (!EventsValidator.isValidMessagingService(s))
            return CommandResult(false, "", "Invalid messaging service data");
        repo.save(s);
        return CommandResult(true, s.id.value, "");
    }

    CommandResult updateService(MessagingServiceDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.serviceId);
        if (existing.isNull) return CommandResult(false, "", "Messaging service not found");
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.region.length > 0) existing.region = dto.region;
        if (dto.maxConnections.length > 0) existing.maxConnections = dto.maxConnections;
        if (dto.maxQueues.length > 0) existing.maxQueues = dto.maxQueues;
        if (dto.maxQueueDepth.length > 0) existing.maxQueueDepth = dto.maxQueueDepth;
        if (dto.maxMessageSize.length > 0) existing.maxMessageSize = dto.maxMessageSize;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteService(TenantId tenantId, MessagingServiceId id) {
        auto s = repo.findById(tenantId, id);
        if (s.isNull) return CommandResult(false, "", "Messaging service not found");
        repo.remove(s);
        return CommandResult(true, s.id.value, "");
    }
}
