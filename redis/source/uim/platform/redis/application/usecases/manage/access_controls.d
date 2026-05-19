/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.redis.application.usecases.manage.access_controls;

import uim.platform.redis;

mixin(ShowModule!());

@safe:

class ManageAccessControlsUseCase {
    private AccessControlRepository repo;

    this(AccessControlRepository repo) { this.repo = repo; }

    AccessControl getAccessControl(TenantId tenantId, AccessControlId id) {
        return repo.findById(tenantId, id);
    }

    AccessControl[] listAccessControls(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    AccessControl[] listByInstance(TenantId tenantId, ServiceInstanceId instanceId) {
        return repo.findByInstance(tenantId, instanceId);
    }

    AccessControl[] listActive(TenantId tenantId) {
        return repo.findByStatus(tenantId, AccessControlStatus.active);
    }

    CommandResult createAccessControl(AccessControlDTO dto) {
        if (repo.cidrExists(dto.tenantId, dto.instanceId, dto.cidr))
            return CommandResult(false, "", "CIDR already exists for this instance");

        AccessControl e;
        e.initEntity(dto.tenantId, dto.createdBy);
        e.id = dto.accessControlId;
        e.instanceId = dto.instanceId;
        e.cidr = dto.cidr;
        e.description = dto.description;
        e.status = AccessControlStatus.active;

        if (!RedisValidator.isValidAccessControl(e))
            return CommandResult(false, "", "Invalid access control: instanceId and CIDR required");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateAccessControl(AccessControlDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.accessControlId);
        if (existing.isNull)
            return CommandResult(false, "", "Access control not found");

        if (dto.description.length > 0) existing.description = dto.description;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteAccessControl(TenantId tenantId, AccessControlId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Access control not found");
        repo.remove(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
