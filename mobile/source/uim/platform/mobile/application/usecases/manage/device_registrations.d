/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.application.usecases.manage.device_registrations;
// import uim.platform.mobile.domain.ports.repositories.device_registrations;
// import uim.platform.mobile.domain.entities.device_registration;

// import uim.platform.mobile.application.dto;


import uim.platform.mobile;

// mixin(Showmodule!());

@safe:
class ManageDeviceRegistrationsUseCase { // TODO: UIMUseCase {
    private DeviceRegistrationRepository repo;

    this(DeviceRegistrationRepository repo) {
        this.repo = repo;
    }

    CommandResult register(RegisterDeviceRequest r) {
        auto existing = repo.findByDeviceToken(r.tenantId, r.deviceToken);
        if (!existing.isNull) {
            existing.osVersion = r.osVersion;
            existing.appVersion = r.appVersion;
            existing.lastConnectedAt = currentTimestamp();
            existing.updatedAt = currentTimestamp();
            repo.update(existing);
            return CommandResult(true, existing.id.value, "");
        }
        DeviceRegistration reg;
        reg.initEntity(r.tenantId);

        reg.appId = r.appId;
        reg.deviceModel = r.deviceModel;
        reg.osVersion = r.osVersion;
        reg.appVersion = r.appVersion;
        reg.platform = parsePlatform(r.platform);
        reg.status = DeviceStatus.registered;
        reg.userId = r.userId;
        reg.deviceToken = r.deviceToken;
        reg.lastConnectedAt = currentTimestamp();
        reg.registeredAt = currentTimestamp();
        reg.updatedAt = reg.registeredAt;

        repo.save(reg);
        return CommandResult(true, reg.id.value, "");
    }

    CommandResult updateStatus(TenantId tenantId, DeviceRegistrationId id, string status) {
        auto reg = repo.findById(tenantId, id);
        if (reg.isNull)
            return CommandResult(false, "", "Device not found");

        switch (status) {
            case "locked": reg.status = DeviceStatus.locked; break;
            case "wiped": reg.status = DeviceStatus.wiped; break;
            case "blocked": reg.status = DeviceStatus.blocked; break;
            default: reg.status = DeviceStatus.registered; break;
        }
        reg.updatedAt = currentTimestamp();
        repo.update(reg);
        return CommandResult(true, reg.id.value, "");
    }

    DeviceRegistration getDeviceRegistration(TenantId tenantId, DeviceRegistrationId id) {
        return repo.findById(tenantId, id);
    }

    DeviceRegistration[] listByApp(TenantId tenantId, MobileAppId appId) {
        return repo.findByApp(tenantId, appId);
    }

    DeviceRegistration[] listByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult deleteDeviceRegistration(TenantId tenantId, DeviceRegistrationId id) {
        auto reg = repo.findById(tenantId, id);
        if (reg.isNull)
            return CommandResult(false, "", "Device not found");

        repo.remove(reg);
        return CommandResult(true, reg.id.value, "Device deleted successfully.");
    }

    size_t countByApp(TenantId tenantId, MobileAppId appId) {
        return repo.countByApp(tenantId, appId);
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

}
