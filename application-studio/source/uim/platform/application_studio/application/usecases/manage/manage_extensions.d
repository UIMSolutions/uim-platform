/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.manage_extensions;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

class ManageExtensionsUseCase { // TODO: UIMUseCase {
    private ExtensionRepository repo;

    this(ExtensionRepository repo) {
        this.repo = repo;
    }

    Extension getById(ExtensionId id) {
        return repo.findById(id);
    }

    Extension[] list() {
        return repo.findAll();
    }

    Extension[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult create(ExtensionDTO dto) {
        Extension e;
        e.id = ExtensionId(dto.id);
        e.tenantId = dto.tenantId;
        e.name = dto.name;
        e.description = dto.description;
        e.version_ = dto.version_;
        e.publisher = dto.publisher;
        e.category = dto.category;
        e.dependencies = dto.dependencies;
        e.capabilities = dto.capabilities;
        e.iconUrl = dto.iconUrl;
        e.createdBy = dto.createdBy;
        if (!StudioValidator.isValidExtension(e))
            return CommandResult(false, "", "Invalid extension data");
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(ExtensionDTO dto) {
        if (!repo.existsById(ExtensionId(dto.id)))
            return CommandResult(false, "", "Extension not found");
        auto existing = repo.findById(ExtensionId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.version_.length > 0) existing.version_ = dto.version_;
        if (dto.modifiedBy.length > 0) existing.modifiedBy = dto.modifiedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(ExtensionId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Extension not found");
        repo.remove(id);
        return CommandResult(true, id.value, "");
    }
}
