/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.usecases.manage.app_builds;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class ManageAppBuildsUseCase { // TODO: UIMUseCase {
    private AppBuildRepository repo;

    this(AppBuildRepository repo) {
        this.repo = repo;
    }

    AppBuild getAppBuild(TenantId tenantId, AppBuildId id) {
        return repo.findById(tenantId, id);
    }

    AppBuild[] listAppBuilds(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    AppBuild[] listAppBuilds(TenantId tenantId, ApplicationId applicationId) {
        return repo.findByApplication(applicationId)
            .filter!(e => e.tenantId.value == tenantId.value)
            .array;
    }

    CommandResult createAppBuild(AppBuildDTO dto) {
        AppBuild e;
        e.initEntity(dto.tenantId, dto.createdBy);
        e.id = dto.appBuildId;
        e.applicationId = dto.applicationId;
        e.name = dto.name;
        e.description = dto.description;
        e.version_ = dto.version_;
        e.buildConfig = dto.buildConfig;
        e.signingConfig = dto.signingConfig;
        if (!BuildAppsValidator.isValidAppBuild(e))
            return CommandResult(false, "", "Invalid app build data");
        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateAppBuild(AppBuildDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.appBuildId);
        if (existing.isNull)
            return CommandResult(false, "", "App build not found");
            
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.version_.length > 0) existing.version_ = dto.version_;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteAppBuild(TenantId tenantId, AppBuildId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "App build not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
