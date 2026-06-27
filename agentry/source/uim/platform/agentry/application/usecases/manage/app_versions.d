/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.application.usecases.manage.app_versions;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class ManageAppVersionsUseCase {
    private AppVersionRepository repo;

    this(AppVersionRepository repo) {
        this.repo = repo;
    }

    AppVersion getAppVersion(TenantId tenantId, AppVersionId id) {
        return repo.find(tenantId, id);
    }

    AppVersion[] listAppVersions(TenantId tenantId) {
        return repo.find(tenantId);
    }

    AppVersion[] listByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return repo.findByMobileApplication(tenantId, appId);
    }

    AppVersion[] listByStatus(TenantId tenantId, AppVersionStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult createAppVersion(AppVersionDTO dto) {
        auto ver = AppVersion(dto.tenantId, dto.versionId, dto.createdBy);
        ver.mobileApplicationId = dto.applicationId;
        ver.definitionId = dto.definitionId;
        ver.versionNumber = dto.versionNumber;
        ver.releaseNotes = dto.releaseNotes;
        ver.artifactUrl = dto.artifactUrl;
        ver.checksum = dto.checksum;
        ver.minOsVersion = dto.minOsVersion;
        ver.changeLog = dto.changeLog;
        ver.isMandatoryUpdate = dto.isMandatoryUpdate;

        if (!AgentryValidator.isValidAppVersion(ver))
            return CommandResult(false, "", "Invalid app version data");

        repo.save(ver);
        return CommandResult(true, ver.id.value, "");
    }

    CommandResult updateAppVersion(AppVersionDTO dto) {
        auto existing = repo.find(dto.tenantId, dto.versionId);
        if (existing.isNull)
            return CommandResult(false, "", "App version not found");

        if (dto.releaseNotes.length > 0) existing.releaseNotes = dto.releaseNotes;
        if (dto.artifactUrl.length > 0) existing.artifactUrl = dto.artifactUrl;
        if (dto.changeLog.length > 0) existing.changeLog = dto.changeLog;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteAppVersion(TenantId tenantId, AppVersionId id) {
        auto entity = repo.find(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "App version not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
