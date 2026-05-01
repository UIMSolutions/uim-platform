/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.usecases.manage.manage_app_builds;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class ManageAppBuildsUseCase { // TODO: UIMUseCase {
    private AppBuildRepository repo;

    this(AppBuildRepository repo) {
        this.repo = repo;
    }

    AppBuild getById(AppBuildId id) {
        return repo.findById(id);
    }

    AppBuild[] list() {
        return repo.findAll();
    }

    AppBuild[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    AppBuild[] listByApplication(ApplicationId applicationId) {
        return repo.findByApplication(applicationId);
    }

    CommandResult create(AppBuildDTO dto) {
        AppBuild e;
        e.id = AppBuildId(dto.id);
        e.tenantId = dto.tenantId;
        e.applicationId = ApplicationId(dto.applicationId);
        e.name = dto.name;
        e.description = dto.description;
        e.version_ = dto.version_;
        e.buildConfig = dto.buildConfig;
        e.signingConfig = dto.signingConfig;
        e.createdBy = dto.createdBy;
        if (!BuildAppsValidator.isValidAppBuild(e))
            return CommandResult(false, "", "Invalid app build data");
        repo.save(e);
        return CommandResult(true, dto.id, "");
    }

    CommandResult update(AppBuildDTO dto) {
        if (!repo.existsById(AppBuildId(dto.id)))
            return CommandResult(false, "", "App build not found");
        auto existing = repo.findById(AppBuildId(dto.id));
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.version_.length > 0) existing.version_ = dto.version_;
        if (dto.updatedBy.length > 0) existing.updatedBy = dto.updatedBy;
        repo.update(existing);
        return CommandResult(true, dto.id, "");
    }

    CommandResult remove(AppBuildId id) {
        if (!repo.existsById(id))
            return CommandResult(false, "", "App build not found");
        repo.remove(id);
        return CommandResult(true, id.value, "");
    }
}
