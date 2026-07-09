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
        auto ver = AppVersion(r.tenantId); //, UserId("test-user"));
        ver.appId = r.appId;
        ver.versionCode = r.versionCode;
        // TODO: ? ver.versionName = r.versionName;
        ver.releaseNotes = r.releaseNotes;
        ver.downloadUrl = r.downloadUrl;
         // TODO: ? ver.fileSize = r.fileSize;
         // TODO: ? ver.checksum = r.checksum;
        ver.minOsVersion = r.minOsVersion;
        ver.mandatory = r.mandatory;
        ver.status = VersionStatus.draft;
        // TODO: ver.releasedAt = r.releasedAt;

        repo.save(ver);
        return CommandResult(true, ver.id.value, "");
    }

    CommandResult updateAppVersion(UpdateAppVersionRequest r) {
        auto ver = repo.findById(r.tenantId, r.versionId);
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
        return repo.findById(tenantId, id);
    }

    // AppVersion getLatestAppVersion(TenantId tenantId, MobileAppId id) {
    //     return repo.findLatest(tenantId, id);
    // }

    AppVersion[] listAppVersions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    AppVersion[] listAppVersions(TenantId tenantId, MobileAppId id) {
        return repo.findByApp(tenantId, id);
    }

    CommandResult deleteAppVersion(TenantId tenantId, AppVersionId id) {
        auto ver = repo.findById(tenantId, id);
        if (ver.isNull)
            return CommandResult(false, "", "App version not found");

        repo.remove(ver);
        return CommandResult(true, ver.id.value, "");
    }

    size_t countAppVersions(TenantId tenantId, MobileAppId id) {
        return repo.countByApp(tenantId, id);
    }
}
