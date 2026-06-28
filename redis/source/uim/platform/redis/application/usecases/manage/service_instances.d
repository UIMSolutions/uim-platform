/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.application.usecases.manage.service_instances;

import uim.platform.redis;

// mixin(ShowModule!());

@safe:

class ManageServiceInstancesUseCase {
    private ServiceInstanceRepository repo;

    this(ServiceInstanceRepository repo) { this.repo = repo; }

    ServiceInstance getServiceInstance(TenantId tenantId, ServiceInstanceId id) {
        return repo.findById(tenantId, id);
    }

    ServiceInstance[] listServiceInstances(TenantId tenantId) {
        return repo.find(tenantId);
    }

    ServiceInstance[] listByStatus(TenantId tenantId, InstanceStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    ServiceInstance[] listActive(TenantId tenantId) {
        return repo.findByStatus(tenantId, InstanceStatus.active);
    }

    CommandResult createServiceInstance(ServiceInstanceDTO dto) {
        if (repo.nameExists(dto.tenantId, dto.name))
            return CommandResult(false, "", "Service instance name already exists");

        ServiceInstance e;
        e.initEntity(dto.tenantId, dto.createdBy);
        e.id = dto.serviceInstanceId;
        e.name = dto.name;
        e.description = dto.description;
        e.planId = dto.planId;
        e.hyperscaler = dto.hyperscaler;
        e.region = dto.region;
        e.redisVersion = dto.redisVersion;
        e.memoryMb = dto.memoryMb;
        e.maxConnections = dto.maxConnections;
        e.tlsEnabled = dto.tlsEnabled;
        e.haEnabled = dto.haEnabled;
        e.persistenceMode = dto.persistenceMode;
        e.status = InstanceStatus.provisioning;

        if (!RedisValidator.isValidServiceInstance(e))
            return CommandResult(false, "", "Invalid service instance: name and planId required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateServiceInstance(ServiceInstanceDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.serviceInstanceId);
        if (existing.isNull)
            return CommandResult(false, "", "Service instance not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.memoryMb > 0) existing.memoryMb = dto.memoryMb;
        if (dto.maxConnections > 0) existing.maxConnections = dto.maxConnections;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteServiceInstance(TenantId tenantId, ServiceInstanceId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Service instance not found");
        repo.remove(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
