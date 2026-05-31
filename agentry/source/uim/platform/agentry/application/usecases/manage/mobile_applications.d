/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.application.usecases.manage.mobile_applications;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class ManageMobileApplicationsUseCase {
    private MobileApplicationRepository repo;

    this(MobileApplicationRepository repo) {
        this.repo = repo;
    }

    MobileApplication getMobileApplication(TenantId tenantId, MobileApplicationId id) {
        return repo.findById(tenantId, id);
    }

    MobileApplication[] listMobileApplications(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    MobileApplication[] listByStatus(TenantId tenantId, AppStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    MobileApplication[] listByPlatform(TenantId tenantId, AppPlatform platform) {
        return repo.findByPlatform(tenantId, platform);
    }

    CommandResult createMobileApplication(MobileApplicationDTO dto) {
        MobileApplication app;
        app.initEntity(dto.tenantId, dto.createdBy);
        app.id = dto.applicationId;
        app.name = dto.name;
        app.description = dto.description;
        app.iconUrl = dto.iconUrl;
        app.category = dto.category;
        app.vendor = dto.vendor;
        app.contactEmail = dto.contactEmail;
        app.backendSystemId = dto.backendSystemId;
        app.offlineCapable = dto.offlineCapable;
        app.pushNotificationsEnabled = dto.pushNotificationsEnabled;
        app.minOsVersion = dto.minOsVersion;
        app.packageName = dto.packageName;

        if (!AgentryValidator.isValidMobileApplication(app))
            return CommandResult(false, "", "Invalid mobile application data");

        repo.save(app);
        return CommandResult(true, app.id.value, "");
    }

    CommandResult updateMobileApplication(MobileApplicationDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.applicationId);
        if (existing.isNull)
            return CommandResult(false, "", "Mobile application not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.iconUrl.length > 0) existing.iconUrl = dto.iconUrl;
        if (dto.category.length > 0) existing.category = dto.category;
        if (dto.vendor.length > 0) existing.vendor = dto.vendor;
        if (dto.contactEmail.length > 0) existing.contactEmail = dto.contactEmail;
        if (dto.minOsVersion.length > 0) existing.minOsVersion = dto.minOsVersion;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteMobileApplication(TenantId tenantId, MobileApplicationId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Mobile application not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
