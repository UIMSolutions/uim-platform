/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.application.usecases.manage.service_instances;

import uim.platform.postgres;

mixin(ShowModule!());

@safe:

class ManageServiceInstancesUseCase {
    private ServiceInstanceRepository repo;

    this(ServiceInstanceRepository repo) { this.repo = repo; }

    ServiceInstance getServiceInstance(TenantId tenantId, ServiceInstanceId id) {
        return repo.findById(tenantId, id);
    }

    ServiceInstance[] listServiceInstances(TenantId tenantId) {
        return repo.findByTenant(tenantId);
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
        e.engineVersion = dto.engineVersion;
        e.memoryGb = dto.memoryGb;
        e.storageGb = dto.storageGb;
        e.sslEnabled = dto.sslEnabled;
        e.multiAz = dto.multiAz;
        e.status = InstanceStatus.provisioning;
        e.port  = 5432;

        if (e.name.length == 0 || e.planId.value.length == 0)
            return CommandResult(false, "", "name and planId are required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateServiceInstance(ServiceInstanceDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.serviceInstanceId);
        if (existing.isNull)
            return CommandResult(false, "", "Service instance not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.memoryGb > 0) existing.memoryGb = dto.memoryGb;
        if (dto.storageGb > 0) existing.storageGb = dto.storageGb;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        existing.multiAz = dto.multiAz;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteServiceInstance(TenantId tenantId, ServiceInstanceId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Service instance not found");
        existing.status = InstanceStatus.deleting;
        repo.update(existing);
        repo.removeById(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
