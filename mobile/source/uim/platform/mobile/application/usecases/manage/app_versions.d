/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.app_versions;
// import uim.platform.mobile.domain.ports.repositories.app_versions;
// import uim.platform.mobile.domain.entities.app_version;
// import uim.platform.mobile.domain.types;
// import uim.platform.mobile.application.dto;
// import std.uuid : randomUUID;

import uim.platform.mobile;

mixin(Showmodule!());

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

    CommandResult updateAppVersion(AppVersionId id, UpdateAppVersionRequest r) {
        auto ver = repo.findById(tenantId, id);
        if (ver.isNull)
            return CommandResult(false, "", "App version not found");
        if (r.releaseNotes.length > 0) ver.releaseNotes = r.releaseNotes;
        if (r.downloadUrl.length > 0) ver.downloadUrl = r.downloadUrl;
        if (r.minOsVersion.length > 0) ver.minOsVersion = r.minOsVersion;
        ver.mandatory = r.mandatory;
        ver.updatedAt = currentTimestamp();
        ver.updatedBy = r.updatedBy;
        repo.update(ver);
        return CommandResult(true, ver.id.value, "");
    }

    AppVersion getAppVersion(AppVersionId id) {
        return repo.findById(tenantId, id);
    }

    AppVersion getLatestAppVersion(MobileAppId appId) {
        return repo.findLatest(appId);
    }

    AppVersion[] listAppVersions(MobileAppId appId) {
        return repo.findByApp(appId);
    }

    CommandResult deleteAppVersion(AppVersionId id) {
        repo.removeById(id);
    }

    size_t countAppVersions(MobileAppId appId) {
        return repo.countByApp(appId);
    }

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;
        return Clock.currStdTime();
    }
}
