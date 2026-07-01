/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.usecases.manage.app_builds;

import uim.platform.build_apps;

// mixin(ShowModule!());

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
        return repo.findByApplication(tenantId, applicationId);
    }

    CommandResult createAppBuild(AppBuildDTO dto) {
        auto e = AppBuild(dto.tenantId, dto.buildId.isNull ? AppBuildId(createId()) : dto.buildId, dto.createdBy);
        e.applicationId = dto.applicationId;
        e.name = dto.name;
        e.description = dto.description;
        if (dto.buildTarget.length > 0)
            e.buildTarget = toBuildTarget(dto.buildTarget);
        e.version_ = dto.version_;
        e.buildConfig = dto.buildConfig;
        e.signingConfig = dto.signingConfig;
        if (!BuildAppsValidator.isValidAppBuild(e))
            return CommandResult(false, "", "Invalid app build data");
        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateAppBuild(AppBuildDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.buildId);
        if (existing.isNull)
            return CommandResult(false, "", "App build not found");
            
        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.buildTarget.length > 0) existing.buildTarget = toBuildTarget(dto.buildTarget);
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

    private static BuildTarget toBuildTarget(string value) {
        switch (value) {
            case "ios":
                return BuildTarget.ios;
            case "android":
                return BuildTarget.android;
            case "webAndMobile":
                return BuildTarget.webAndMobile;
            case "web":
            default:
                return BuildTarget.web;
        }
    }
}
