/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.dev_spaces;

import uim.platform.application_studio;
mixin(ShowModule!());

@safe:

class ManageDevSpacesUseCase { // TODO: UIMUseCase {
    private DevSpaceRepository repo;

    this(DevSpaceRepository repo) {
        this.repo = repo;
    }

    DevSpace getDevSpace(TenantId tenantId, DevSpaceId id) {
        return repo.findById(tenantId, id);
    }

    DevSpace[] listDevSpaces(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DevSpace[] listDevSpaces(TenantId tenantId, string owner) {
        return repo.findByOwner(tenantId, owner);
    }

    CommandResult createDevSpace(DevSpaceDTO dto) {
        DevSpace e;
        e.id = dto.spaceId;
        e.tenantId = dto.tenantId;
        e.name = dto.name;
        e.description = dto.description;
        e.devSpaceTypeId = dto.typeId;
        e.extensions = dto.extensions;
        e.owner = dto.owner;
        e.region = dto.region;
        e.hibernateAfterDays = dto.hibernateAfterDays;
        e.memoryLimit = dto.memoryLimit;
        e.diskLimit = dto.diskLimit;
        e.createdBy = dto.createdBy;
        if (!StudioValidator.isValidDevSpace(e))
            return CommandResult(false, "", "Invalid dev space data");
        repo.save(e);
        return CommandResult(true, dto.spaceId.value, "");
    }

    CommandResult updateDevSpace(DevSpaceDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.spaceId);
        if (existing.isNull)
            return CommandResult(false, "", "Dev space not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.extensions.length > 0) existing.extensions = dto.extensions;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, dto.spaceId.value, "");
    }

    CommandResult deleteDevSpace(TenantId tenantId, DevSpaceId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Dev space not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
