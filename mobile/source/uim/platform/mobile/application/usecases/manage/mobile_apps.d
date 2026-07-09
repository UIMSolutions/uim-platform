/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.mobile_apps;
// import uim.platform.mobile.domain.ports.repositories.mobile_apps;
// import uim.platform.mobile.domain.entities.mobile_app;

// import uim.platform.mobile.application.dto;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

class ManageMobileAppsUseCase { // TODO: UIMUseCase {
    private MobileAppRepository repo;

    this(MobileAppRepository repo) {
        this.repo = repo;
    }

    CommandResult createMobileApp(CreateMobileAppRequest r) {
        auto existing = repo.findByBundleId(r.tenantId, r.bundleId);
        if (!existing.isNull)
            return CommandResult(false, "", "App with this bundle ID already exists");
        
        auto app = MobileApp(r.tenantId); //, UserId("test-user"));
        app.name = r.name;
        app.description = r.description;
        app.bundleId = r.bundleId;
        app.platform = r.platform.toAppPlatform;
        app.status = AppStatus.active;
        app.securityConfig = r.securityConfig;
        app.authProvider = r.authProvider;
        app.pushEnabled = r.pushEnabled;
        app.offlineEnabled = r.offlineEnabled;
        app.iconUrl = r.iconUrl;

        repo.save(app);
        return CommandResult(true, app.id.value, "");
    }

    CommandResult updateMobileApp(UpdateMobileAppRequest r) {
        auto app = repo.findById(r.tenantId, r.appId);
        if (app.isNull)
            return CommandResult(false, "", "App not found");

        if (r.description.length > 0) app.description = r.description;
        if (r.securityConfig.length > 0) app.securityConfig = r.securityConfig;
        if (r.authProvider.length > 0) app.authProvider = r.authProvider;
        if (r.iconUrl.length > 0) app.iconUrl = r.iconUrl;
        app.pushEnabled = r.pushEnabled;
        app.offlineEnabled = r.offlineEnabled;
        app.updatedAt = currentTimestamp();
        app.updatedBy = r.updatedBy;
        repo.update(app);
        return CommandResult(true, app.id.value, "");
    }

    MobileApp getMobileApp(TenantId tenantId, MobileAppId id) {
        return repo.findById(tenantId, id);
    }

    MobileApp[] listMobileAppsByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult deleteMobileApp(TenantId tenantId, MobileAppId id) {
        auto app = repo.findById(tenantId, id);
        if (app.isNull)
            return CommandResult(false, "", "App not found");

        repo.remove(app);
        return CommandResult(true, app.id.value, "");
    }

    size_t countMobileAppsByTenant(TenantId tenantId) {
        return repo.countByTenant(tenantId);
    }

}
