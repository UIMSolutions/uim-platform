/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.application.usecases.manage.applications;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

class ManageApplicationsUseCase { // TODO: UIMUseCase {
    private IApplicationRepository repo;

    this(IApplicationRepository repo) {
        this.repo = repo;
    }

    Application getApplication(TenantId tenantId, ApplicationId id) {
        return repo.findById(tenantId, id);
    }

    Application[] listApplications(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Application[] listApplications(TenantId tenantId, string owner) {
        return repo.findByOwner(tenantId, owner);
    }

    CommandResult createApplication(ApplicationDTO dto) {
        auto e = Application(dto.tenantId, dto.applicationId.isNull ? ApplicationId(createId()) : dto.applicationId, dto.createdBy);
        e.name = dto.name;
        e.description = dto.description;
        e.version_ = dto.version_;
        e.iconUrl = dto.iconUrl;
        e.themeConfig = dto.themeConfig;
        e.globalVariables = dto.globalVariables;
        e.defaultLanguage = dto.defaultLanguage;
        e.supportedLanguages = dto.supportedLanguages;
        e.owner = dto.owner;
        if (!BuildAppsValidator.isValidApplication(e))
            return CommandResult(false, "", "Invalid application data");

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    CommandResult updateApplication(ApplicationDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.applicationId);
        if (existing.isNull)
            return CommandResult(false, "", "Application not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.version_.length > 0) existing.version_ = dto.version_;
        if (dto.iconUrl.length > 0) existing.iconUrl = dto.iconUrl;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteApplication(TenantId tenantId, ApplicationId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Application not found");
            
        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}

///
unittest {
    auto repo = new ApplicationRepository();
    auto usecase = new ManageApplicationsUseCase(repo);
    auto tenantId = TenantId("test-tenant");

    // Test create
    ApplicationDTO createDto;
    createDto.tenantId = tenantId;
    createDto.applicationId = ApplicationId("application-1");
    createDto.name = "Test Application";
    auto createResult = usecase.createApplication(createDto);
    assert(createResult.success, createResult.message);

    // Test list
    auto items = usecase.listApplications(tenantId);
    assert(items.length == 1);

    // Test get
    auto item = usecase.getApplication(tenantId, ApplicationId("application-1"));
    assert(!item.isNull);

    // Test update
    ApplicationDTO updateDto;
    updateDto.tenantId = tenantId;
    updateDto.applicationId = ApplicationId("application-1");
    updateDto.name = "Updated Application";
    auto updateResult = usecase.updateApplication(updateDto);
    assert(updateResult.success, updateResult.message);

    // Test delete
    auto deleteResult = usecase.deleteApplication(tenantId, ApplicationId("application-1"));
    assert(deleteResult.success, deleteResult.message);
    assert(usecase.listApplications(tenantId).length == 0);

}
