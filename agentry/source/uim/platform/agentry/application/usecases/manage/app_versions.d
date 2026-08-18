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
    protected IAppVersionRepository repo;

    this(IAppVersionRepository repo) {
        this.repo = repo;
    }

    AppVersion getAppVersion(TenantId tenantId, AppVersionId id) {
        return repo.findById(tenantId, id);
    }

    AppVersion[] listAppVersions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    AppVersion[] listByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return repo.findByMobileApplication(tenantId, appId);
    }

    AppVersion[] listByStatus(TenantId tenantId, AppVersionStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    UsecaseResult createAppVersion(AppVersionDTO dto) {
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
            return UsecaseResult(false, "", "Invalid app version data");

        repo.save(ver);
        return UsecaseResult(true, ver.id.value, "");
    }

    UsecaseResult updateAppVersion(AppVersionDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.versionId);
        if (existing.isNull)
            return UsecaseResult(false, "", "App version not found");

        if (dto.releaseNotes.length > 0) existing.releaseNotes = dto.releaseNotes;
        if (dto.artifactUrl.length > 0) existing.artifactUrl = dto.artifactUrl;
        if (dto.changeLog.length > 0) existing.changeLog = dto.changeLog;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult deleteAppVersion(TenantId tenantId, AppVersionId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return UsecaseResult(false, "", "App version not found");

        repo.remove(entity);
        return UsecaseResult(true, entity.id.value, "");
    }
}

///
unittest {
    // auto repo = new AppVersionRepository();
    // auto usecase = new ManageAppVersionsUseCase(repo);
    // auto tenantId = TenantId("test-tenant");

    // Test create
    // AppVersionDTO createDto;
    // createDto.tenantId = tenantId;
    // createDto.appVersionId = AppVersionId("appVersion-1");
    // createDto.name = "Test AppVersion";
    // auto createResult = usecase.createAppVersion(createDto);
    // assert(createResult.success, createResult.message);

    // Test list
    // auto items = usecase.listAppVersions(tenantId);
    // assert(items.length == 1);

    // Test get
    // auto item = usecase.getAppVersion(tenantId, AppVersionId("appVersion-1"));
    // assert(!item.isNull);
// 
    // // Test update
    // AppVersionDTO updateDto;
    // updateDto.tenantId = tenantId;
    // updateDto.appVersionId = AppVersionId("appVersion-1");
    // updateDto.name = "Updated AppVersion";
    // auto updateResult = usecase.updateAppVersion(updateDto);
    // assert(updateResult.success, updateResult.message);
// 
    // // Test delete
    // auto deleteResult = usecase.deleteAppVersion(tenantId, AppVersionId("appVersion-1"));
    // assert(deleteResult.success, deleteResult.message);
    // assert(usecase.listAppVersions(tenantId).length == 0);

}
