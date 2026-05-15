/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.application.usecases.manage.app_versions;
// import uim.platform.html_repository.domain.ports.repositories.app_versions;
// import uim.platform.html_repository.domain.entities.app_version;
// import uim.platform.html_repository.domain.services.deployment_validator;
// import uim.platform.html_repository.domain.types;
// import uim.platform.html_repository.application.dto;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class ManageAppVersionsUseCase { // TODO: UIMUseCase {
    private AppVersionRepository repo;

    this(AppVersionRepository repo) {
        this.repo = repo;
    }

    CommandResult createAppVersion(CreateAppVersionRequest r) {
        if (!DeploymentValidator.validateVersionCode(r.versionCode))
            return CommandResult(false, "", "Invalid version code");

        AppVersion ver;
        ver.initEntity(r.tenantId, r.createdBy);

        ver.appId = r.appId;
        ver.versionCode = r.versionCode;
        ver.description = r.description;
        ver.status = VersionStatus.draft;
        ver.totalSizeBytes = 0;

        repo.save(ver);
        return CommandResult(true, ver.id.value, "");
    }

    CommandResult updateAppVersion(TenantId tenantId, AppVersionId id, UpdateAppVersionRequest r) {
        auto ver = repo.findById(tenantId, id);
        if (ver.isNull)
            return CommandResult(false, "", "Version not found");

        if (r.description.length > 0) ver.description = r.description;
        if (r.status.length > 0) ver.status = parseVersionStatus(r.status);
        ver.updatedAt = currentTimestamp();
        ver.updatedBy = r.updatedBy;

        repo.update(ver);
        return CommandResult(true, ver.id.value, "");
    }

    AppVersion getAppVersionById(TenantId tenantId, AppVersionId id) {
        return repo.findById(tenantId, id);
    }

    AppVersion getLatestAppVersion(TenantId tenantId, HtmlAppId appId) {
        return repo.findLatestByApp(tenantId, appId);
    }

    AppVersion[] listAppVersions(TenantId tenantId, HtmlAppId appId) {
        return repo.findByApp(tenantId, appId);
    }

    CommandResult deleteAppVersion(TenantId tenantId, AppVersionId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Version not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }

    size_t countByApp(HtmlAppId appId) {
        return repo.countByApp(appId);
    }

    private static VersionStatus parseVersionStatus(string s) {
        switch (s) {
            case "draft": return VersionStatus.draft;
            case "active": return VersionStatus.active;
            case "inactive": return VersionStatus.inactive;
            default: return VersionStatus.draft;
        }
    }

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;
        return Clock.currStdTime();
    }
}
