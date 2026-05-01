/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.manage_dev_space_types;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class ManageDevSpaceTypesUseCase { // TODO: UIMUseCase {
    private DevSpaceTypeRepository repo;

    this(DevSpaceTypeRepository repo) {
        this.repo = repo;
    }

    DevSpaceType getById(DevSpaceTypeId id) {
        return repo.findById(id);
    }

    DevSpaceType[] list() {
        return repo.findAll();
    }

    DevSpaceType[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult create(DevSpaceTypeDTO dto) {
        DevSpaceType e;
        e.id = DevSpaceTypeId(dto.id);
        e.tenantId = dto.tenantId;
        e.name = dto.name;
        e.description = dto.description;
        e.predefinedExtensions = dto.predefinedExtensions;
        e.supportedProjectTypes = dto.supportedProjectTypes;
        e.runtimeStack = dto.runtimeStack;
        e.iconUrl = dto.iconUrl;
        e.createdBy = dto.createdBy;
        if (!StudioValidator.isValidDevSpaceType(e))
            return CommandResult(false, "", "Invalid dev space type data");
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(DevSpaceTypeDTO dto) {
        if (!repo.existsById(DevSpaceTypeId(dto.id)))
            return CommandResult(false, "", "Dev space type not found");
        auto existing = repo.findById(DevSpaceTypeId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.predefinedExtensions.length > 0) existing.predefinedExtensions = dto.predefinedExtensions;
        if (dto.updatedBy.length > 0) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(DevSpaceTypeId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Dev space type not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
