/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.application.usecases.manage.devices;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class ManageDevicesUseCase {
    protected IDeviceRepository repo;

    this(IDeviceRepository repo) {
        this.repo = repo;
    }

    MobileDevice getDevice(TenantId tenantId, DeviceId id) {
        return repo.findById(tenantId, id);
    }

    MobileDevice[] listDevices(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    MobileDevice[] listByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return repo.findByMobileApplication(tenantId, appId);
    }

    MobileDevice[] listByStatus(TenantId tenantId, DeviceStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    MobileDevice[] listByGroup(TenantId tenantId, string groupName) {
        return repo.findByGroup(tenantId, groupName);
    }

    UsecaseResult enrollDevice(DeviceDTO dto) {
        auto device = MobileDevice(dto.tenantId, dto.deviceId, dto.createdBy);
        device.mobileApplicationId = dto.applicationId;
        device.deviceName = dto.deviceName;
        device.deviceModel = dto.deviceModel;
        device.manufacturer = dto.manufacturer;
        device.osVersion = dto.osVersion;
        device.appVersionInstalled = dto.appVersionInstalled;
        device.pushToken = dto.pushToken;
        device.userId = dto.userId;
        device.userEmail = dto.userEmail;
        device.groupName = dto.groupName;
        device.isManaged = dto.isManaged;
        device.mdmDeviceId = dto.mdmDeviceId;

        if (!AgentryValidator.isValidDevice(device))
            return UsecaseResult(false, "", "Invalid device data");

        repo.save(device);
        return UsecaseResult(true, device.id.value, "");
    }

    UsecaseResult updateDevice(DeviceDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.deviceId);
        if (existing.isNull)
            return UsecaseResult(false, "", "MobileDevice not found");

        if (dto.appVersionInstalled.length > 0) existing.appVersionInstalled = dto.appVersionInstalled;
        if (dto.osVersion.length > 0) existing.osVersion = dto.osVersion;
        if (dto.groupName.length > 0) existing.groupName = dto.groupName;
        if (dto.pushToken.length > 0) existing.pushToken = dto.pushToken;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return UsecaseResult(true, existing.id.value, "");
    }

    UsecaseResult removeDevice(TenantId tenantId, DeviceId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return UsecaseResult(false, "", "MobileDevice not found");

        repo.remove(entity);
        return UsecaseResult(true, entity.id.value, "");
    }
}

///
unittest {
//     auto repo = new IDeviceRepository();
//     auto usecase = new ManageDevicesUseCase(repo);
//     auto tenantId = TenantId("test-tenant");
// 
//     // Test list
//     auto items = usecase.listDevices(tenantId);
//     assert(items !is null);

}
