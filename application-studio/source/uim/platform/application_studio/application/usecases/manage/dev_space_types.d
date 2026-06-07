/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.dev_space_types;

import uim.platform.application_studio;

// mixin(ShowModule!());

@safe:

class ManageDevSpaceTypesUseCase { // TODO: UIMUseCase {
    private DevSpaceTypeRepository spaceTypes;

    this(DevSpaceTypeRepository spaceTypes) {
        this.spaceTypes = spaceTypes;
    }

    DevSpaceType getDevSpaceType(DevSpaceTypeId id) {
        return spaceTypes.findById(tenantId, id);
    }

    DevSpaceType[] listDevSpaceTypes(TenantId tenantId) {
        return spaceTypes.findByTenant(tenantId);
    }

    CommandResult createDevSpaceType(DevSpaceTypeDTO dto) {
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
        spaceTypes.save(e);
        return CommandResult(true, dto.id.value, "");
    }

    CommandResult updateDevSpaceType(DevSpaceTypeDTO dto) {
        auto existing = spaceTypes.findById(DevSpaceTypeId(dto.id));
        if (existing.isNull) 
            return CommandResult(false, "", "Dev space type not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.predefinedExtensions.length > 0) existing.predefinedExtensions = dto.predefinedExtensions;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        spaceTypes.update(existing);
        return CommandResult(true, dto.id.value, "");
    }

    CommandResult deleteDevSpaceType(DevSpaceTypeId id) {
        auto type = spaceTypes.findById(tenantId, id);
        if (type.isNull)
            return CommandResult(false, "", "Dev space type not found");

        spaceTypes.remove(type);
        return CommandResult(true, type.id.value, "");
    }
}
