/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.usecases.manage.applications;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class ManageApplicationsUseCase { // TODO: UIMUseCase {
    private ApplicationRepository repo;

    this(ApplicationRepository repo) {
        this.repo = repo;
    }

    Application getById(ApplicationId id) {
        return repo.findById(id);
    }

    Application[] list() {
        return repo.findAll();
    }

    Application[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Application[] listByOwner(string owner) {
        return repo.findByOwner(owner);
    }

    CommandResult create(ApplicationDTO dto) {
        Application e;
        e.id = ApplicationId(dto.id);
        e.tenantId = dto.tenantId;
        e.name = dto.name;
        e.description = dto.description;
        e.version_ = dto.version_;
        e.iconUrl = dto.iconUrl;
        e.themeConfig = dto.themeConfig;
        e.globalVariables = dto.globalVariables;
        e.defaultLanguage = dto.defaultLanguage;
        e.supportedLanguages = dto.supportedLanguages;
        e.owner = dto.owner;
        e.createdBy = dto.createdBy;
        if (!BuildAppsValidator.isValidApplication(e))
            return CommandResult(false, "", "Invalid application data");
        repo.save(e);
        return CommandResult(true, dto.id.value, "");
    }

    CommandResult update(ApplicationDTO dto) {
        if (!repo.existsById(ApplicationId(dto.id)))
            return CommandResult(false, "", "Application not found");
        auto existing = repo.findById(ApplicationId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.version_.length > 0) existing.version_ = dto.version_;
        if (dto.iconUrl.length > 0) existing.iconUrl = dto.iconUrl;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id.value, "");
    }

    CommandResult remove(ApplicationId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "Application not found");
        repo.removeById(id);
        return CommandResult(true, id.value, "");
    }
}
