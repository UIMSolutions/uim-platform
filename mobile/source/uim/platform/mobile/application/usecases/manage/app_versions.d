/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.app_versions;
// import uim.platform.mobile.domain.ports.repositories.app_versions;
// import uim.platform.mobile.domain.entities.app_version;

// import uim.platform.mobile.application.dto;


import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
class ManageAppVersionsUseCase { // TODO: UIMUseCase {
    private AppVersionRepository repo;

    this(AppVersionRepository repo) {
        this.repo = repo;
    }

    CommandResult createAppVersion(CreateAppVersionRequest r) {
        AppVersion ver;
        ver.initEntity(r.tenantId, r.createdBy);

        ver.appId = r.appId;
        ver.versionCode = r.versionCode;
        ver.versionName = r.versionName;
        ver.releaseNotes = r.releaseNotes;
        ver.downloadUrl = r.downloadUrl;
        ver.fileSize = r.fileSize;
        ver.checksum = r.checksum;
        ver.minOsVersion = r.minOsVersion;
        ver.mandatory = r.mandatory;
        ver.status = VersionStatus.draft;
        ver.releasedAt = r.releasedAt;

        repo.save(ver);
        return CommandResult(true, ver.id.value, "");
    }

    CommandResult updateAppVersion(UpdateAppVersionRequest r) {
        auto ver = repo.find(r.tenantId, r.versionId);
        if (ver.isNull)
            return CommandResult(false, "", "App version not found");
        if (r.releaseNotes.length > 0)
            ver.releaseNotes = r.releaseNotes;
        if (r.downloadUrl.length > 0)
            ver.downloadUrl = r.downloadUrl;
        if (r.minOsVersion.length > 0)
            ver.minOsVersion = r.minOsVersion;
        ver.mandatory = r.mandatory;
        ver.updatedAt = currentTimestamp();
        ver.updatedBy = r.updatedBy;

        repo.update(ver);
        return CommandResult(true, ver.id.value, "");
    }

    AppVersion getAppVersion(TenantId tenantId, AppVersionId id) {
        return repo.find(tenantId, id);
    }

    AppVersion getLatestAppVersion(TenantId tenantId, MobileAppId appId) {
        return repo.findLatest(tenantId, appId);
    }

    AppVersion[] listAppVersions(TenantId tenantId, MobileAppId appId) {
        return repo.findByApp(tenantId, appId);
    }

    CommandResult deleteAppVersion(TenantId tenantId, AppVersionId id) {
        auto ver = repo.find(tenantId, id);
        if (ver.isNull)
            return CommandResult(false, "", "App version not found");

        repo.remove(ver);
        return CommandResult(true, ver.id.value, "");
    }

    size_t countAppVersions(TenantId tenantId, MobileAppId appId) {
        return repo.countByApp(tenantId, appId);
    }
}
