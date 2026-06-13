/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.extensions;

import uim.platform.application_studio;

// mixin(ShowModule!());

@safe:

class ManageExtensionsUseCase { // TODO: UIMUseCase {
    private ExtensionRepository extensions;

    this(ExtensionRepository extensions) {
        this.extensions = extensions;
    }

    Extension getExtension(TenantId tenantId, ExtensionId id) {
        return extensions.findById(tenantId, id);
    }

    Extension[] listExtensions(TenantId tenantId) {
        return extensions.findByTenant(tenantId);
    }

    CommandResult createExtension(ExtensionDTO dto) {
        Extension e;
        e.initEntity(dto.tenantId, dto.createdBy);
        
        e.id = dto.extensionId;
        e.name = dto.name;
        e.description = dto.description;
        e.version_ = dto.version_;
        e.publisher = dto.publisher;
        e.category = dto.category;
        e.dependencies = dto.dependencies;
        e.capabilities = dto.capabilities;
        e.iconUrl = dto.iconUrl;
        if (!StudioValidator.isValidExtension(e))
            return CommandResult(false, "", "Invalid extension data");

        extensions.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateExtension(ExtensionDTO dto) {
        auto existing = extensions.findById(dto.tenantId, dto.extensionId);
        if (existing.isNull)
            return CommandResult(false, "", "Extension not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.version_.length > 0) existing.version_ = dto.version_;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        extensions.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteExtension(TenantId tenantId, ExtensionId id) {
        auto extension = extensions.findById(tenantId, id);
        if (extension.isNull)
            return CommandResult(false, "", "Extension not found");

        extensions.remove(extension);
        return CommandResult(true, extension.id.value, "");
    }
}
