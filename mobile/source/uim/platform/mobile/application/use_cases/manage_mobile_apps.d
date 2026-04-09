/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.mobile_apps;

import uim.platform.mobile.domain.ports.repositories.mobile_apps;
import uim.platform.mobile.domain.entities.mobile_app;
import uim.platform.mobile.domain.types;
import uim.platform.mobile.application.dto;
import std.uuid : randomUUID;
import std.conv : to;

class ManageMobileAppsUseCase : UIMUseCase {
    private MobileAppRepository repo;

    this(MobileAppRepository repo) {
        this.repo = repo;
    }

    CommandResult create(CreateMobileAppRequest r) {
        auto existing = repo.findByBundleId(r.bundleId);
        if (existing.id.length > 0)
            return CommandResult(false, "", "App with this bundle ID already exists");
        MobileApp app;
        app.id = randomUUID();
        app.tenantId = r.tenantId;
        app.name = r.name;
        app.description = r.description;
        app.bundleId = r.bundleId;
        app.platform = parsePlatform(r.platform);
        app.status = AppStatus.active;
        app.securityConfig = r.securityConfig;
        app.authProvider = r.authProvider;
        app.pushEnabled = r.pushEnabled;
        app.offlineEnabled = r.offlineEnabled;
        app.iconUrl = r.iconUrl;
        app.createdAt = currentTimestamp();
        app.updatedAt = app.createdAt;
        app.createdBy = r.createdBy;
        app.modifiedBy = r.createdBy;
        repo.save(app);
        return CommandResult(true, app.id, "");
    }

    CommandResult update(MobileAppId id, UpdateMobileAppRequest r) {
        auto app = repo.findById(id);
        if (app.id.isEmpty)
            return CommandResult(false, "", "App not found");
        if (r.description.length > 0) app.description = r.description;
        if (r.securityConfig.length > 0) app.securityConfig = r.securityConfig;
        if (r.authProvider.length > 0) app.authProvider = r.authProvider;
        if (r.iconUrl.length > 0) app.iconUrl = r.iconUrl;
        app.pushEnabled = r.pushEnabled;
        app.offlineEnabled = r.offlineEnabled;
        app.updatedAt = currentTimestamp();
        app.modifiedBy = r.modifiedBy;
        repo.update(app);
        return CommandResult(true, app.id, "");
    }

    MobileApp get_(MobileAppId id) {
        return repo.findById(id);
    }

    MobileApp[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    void remove(MobileAppId id) {
        repo.remove(id);
    }

    long countByTenant(TenantId tenantId) {
        return repo.countByTenant(tenantId);
    }

    private static AppPlatform parsePlatform(string s) {
        switch (s) {
            case "ios": return AppPlatform.ios;
            case "android": return AppPlatform.android;
            case "windows": return AppPlatform.windows;
            case "web": return AppPlatform.web;
            default: return AppPlatform.ios;
        }
    }

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;
        return Clock.currStdTime();
    }
}
