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

    DevSpace getById(DevSpaceId id) {
        return repo.findById(id);
    }

    DevSpace[] list() {
        return repo.findAll();
    }

    DevSpace[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DevSpace[] listByOwner(string owner) {
        return repo.findByOwner(owner);
    }

    CommandResult create(DevSpaceDTO dto) {
        DevSpace e;
        e.id = dto.devSpaceId;
        e.tenantId = dto.tenantId;
        e.name = dto.name;
        e.description = dto.description;
        e.devSpaceTypeId = DevSpaceTypeId(dto.devSpaceTypeId);
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
        return CommandResult(true, dto.devSpaceId.value, "");
    }

    CommandResult update(DevSpaceDTO dto) {
        if (!repo.existsById(dto.devSpaceId))
            return CommandResult(false, "", "Dev space not found");
        auto existing = repo.findById(dto.devSpaceId);
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.extensions.length > 0) existing.extensions = dto.extensions;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.devSpaceId.value, "");
    }

    CommandResult remove(DevSpaceId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Dev space not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
