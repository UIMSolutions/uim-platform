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
class ManageAppVersionsUseCase {
    private IAppVersionRepository repo;

    this(IAppVersionRepository repo) {
        this.repo = repo;
    }

    UsecaseResult createAppVersion(CreateAppVersionRequest r) {
        if (!DeploymentValidator.validateVersionCode(r.versionCode))
            return UsecaseResult(false, "", "Invalid version code");

        auto ver = AppVersion(r.tenantId);
        ver.appId = r.appId;
        ver.versionCode = r.versionCode;
        ver.description = r.description;
        ver.status = VersionStatus.active;
        ver.totalSizeBytes = 0;

        repo.save(ver);
        return UsecaseResult(true, ver.id.value, "");
    }

    UsecaseResult updateAppVersion(TenantId tenantId, AppVersionId id, UpdateAppVersionRequest r) {
        auto ver = repo.findById(tenantId, id);
        if (ver.isNull)
            return UsecaseResult(false, "", "Version not found");

        if (r.description.length > 0) ver.description = r.description;
        if (r.status.length > 0) ver.status = r.status.toVersionStatus;
        ver.updatedAt = currentTimestamp();
        // ver.updatedBy = r.updatedBy;

        repo.update(ver);
        return UsecaseResult(true, ver.id.value, "");
    }

    AppVersion getAppVersion(TenantId tenantId, AppVersionId id) {
        return repo.findById(tenantId, id);
    }

    AppVersion getLatestAppVersion(TenantId tenantId, HtmlAppId appId) {
        return repo.findLatest(tenantId, appId);
    }

    AppVersion[] listAppVersions(TenantId tenantId, HtmlAppId appId) {
        return repo.findByApp(tenantId, appId);
    }

    UsecaseResult deleteAppVersion(TenantId tenantId, AppVersionId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return UsecaseResult(false, "", "Version not found");

        repo.remove(entity);
        return UsecaseResult(true, entity.id.value, "");
    }

    size_t countByApp(TenantId tenantId, HtmlAppId appId) {
        return repo.countByApp(tenantId, appId);
    }

}
