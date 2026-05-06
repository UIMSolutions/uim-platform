/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.usecases.manage.ui_components;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class ManageUIComponentsUseCase { // TODO: UIMUseCase {
    private UIComponentRepository repo;

    this(UIComponentRepository repo) {
        this.repo = repo;
    }

    UIComponent getById(UIComponentId id) {
        return repo.findById(id);
    }

    UIComponent[] list() {
        return repo.findAll();
    }

    UIComponent[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult create(UIComponentDTO dto) {
        UIComponent e;
        e.id = UIComponentId(dto.id);
        e.tenantId = dto.tenantId;
        e.name = dto.name;
        e.description = dto.description;
        e.version_ = dto.version_;
        e.properties = dto.properties;
        e.styleProperties = dto.styleProperties;
        e.eventBindings = dto.eventBindings;
        e.dataBindings = dto.dataBindings;
        e.childComponents = dto.childComponents;
        e.iconUrl = dto.iconUrl;
        e.previewUrl = dto.previewUrl;
        e.createdBy = dto.createdBy;
        if (!BuildAppsValidator.isValidUIComponent(e))
            return CommandResult(false, "", "Invalid UI component data");
        repo.save(e);
        return CommandResult(true, dto.id.value, "");
    }

    CommandResult update(UIComponentDTO dto) {
        if (!repo.existsById(UIComponentId(dto.id)))
            return CommandResult(false, "", "UI component not found");
        auto existing = repo.findById(UIComponentId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.version_.length > 0) existing.version_ = dto.version_;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id.value, "");
    }

    CommandResult remove(UIComponentId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "UI component not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
