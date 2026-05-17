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
    private DeviceRepository repo;

    this(DeviceRepository repo) {
        this.repo = repo;
    }

    Device getDevice(TenantId tenantId, DeviceId id) {
        return repo.findById(tenantId, id);
    }

    Device[] listDevices(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Device[] listByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return repo.findByMobileApplication(tenantId, appId);
    }

    Device[] listByStatus(TenantId tenantId, DeviceStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    Device[] listByGroup(TenantId tenantId, string groupName) {
        return repo.findByGroup(tenantId, groupName);
    }

    CommandResult enrollDevice(DeviceDTO dto) {
        Device device;
        device.initEntity(dto.tenantId, dto.createdBy);
        device.id = dto.deviceId;
        device.mobileApplicationId = dto.mobileApplicationId;
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
            return CommandResult(false, "", "Invalid device data");

        repo.save(device);
        return CommandResult(true, device.id.value, "");
    }

    CommandResult updateDevice(DeviceDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.deviceId);
        if (existing.isNull)
            return CommandResult(false, "", "Device not found");

        if (dto.appVersionInstalled.length > 0) existing.appVersionInstalled = dto.appVersionInstalled;
        if (dto.osVersion.length > 0) existing.osVersion = dto.osVersion;
        if (dto.groupName.length > 0) existing.groupName = dto.groupName;
        if (dto.pushToken.length > 0) existing.pushToken = dto.pushToken;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult removeDevice(TenantId tenantId, DeviceId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Device not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
