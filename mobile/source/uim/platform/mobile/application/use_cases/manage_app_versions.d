/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.use_cases.manage_app_versions;

import uim.platform.mobile.domain.ports.app_version_repository;
import uim.platform.mobile.domain.entities.app_version;
import uim.platform.mobile.domain.types;
import uim.platform.mobile.application.dto;
import std.uuid : randomUUID;
import std.conv : to;

class ManageAppVersionsUseCase {
    private AppVersionRepository repo;

    this(AppVersionRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateAppVersionRequest r) {
        AppVersion ver;
        ver.id = randomUUID().to!string;
        ver.tenantId = r.tenantId;
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
        ver.createdAt = currentTimestamp();
        ver.updatedAt = ver.createdAt;
        ver.createdBy = r.createdBy;
        repo.save(ver);
        return CommandResult(true, ver.id, "");
    }

    CommandResult update(AppVersionId id, UpdateAppVersionRequest r) {
        auto ver = repo.findById(id);
        if (ver.id.length == 0)
            return CommandResult(false, "", "App version not found");
        if (r.releaseNotes.length > 0) ver.releaseNotes = r.releaseNotes;
        if (r.downloadUrl.length > 0) ver.downloadUrl = r.downloadUrl;
        if (r.minOsVersion.length > 0) ver.minOsVersion = r.minOsVersion;
        ver.mandatory = r.mandatory;
        ver.updatedAt = currentTimestamp();
        ver.modifiedBy = r.modifiedBy;
        repo.update(ver);
        return CommandResult(true, ver.id, "");
    }

    AppVersion get_(AppVersionId id) {
        return repo.findById(id);
    }

    AppVersion getLatest(MobileAppId appId) {
        return repo.findLatest(appId);
    }

    AppVersion[] listByApp(MobileAppId appId) {
        return repo.findByApp(appId);
    }

    void remove(AppVersionId id) {
        repo.remove(id);
    }

    long countByApp(MobileAppId appId) {
        return repo.countByApp(appId);
    }

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;
        return Clock.currStdTime();
    }
}
