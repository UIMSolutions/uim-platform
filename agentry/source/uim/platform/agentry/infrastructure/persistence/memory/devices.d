/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.persistence.memory.devices;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class MemoryDeviceRepository : TenantRepository!(Device, DeviceId), DeviceRepository {
    mixin TenantRepositoryTemplate!(MemoryDeviceRepository, Device, DeviceId);

    size_t countByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return findByMobileApplication(tenantId, appId).length;
    }

    Device[] filterByMobileApplication(Device[] devices, MobileApplicationId appId) {
        return devices.filter!(d => d.mobileApplicationId == appId).array;
    }

    Device[] findByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return filterByMobileApplication(find(tenantId), appId);
    }

    void removeByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        findByMobileApplication(tenantId, appId).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, DeviceStatus status) {
        return findByStatus(tenantId, status).length;
    }

    Device[] filterByStatus(Device[] devices, DeviceStatus status) {
        return devices.filter!(d => d.status == status).array;
    }

    Device[] findByStatus(TenantId tenantId, DeviceStatus status) {
        return filterByStatus(find(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, DeviceStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

    size_t countByPlatform(TenantId tenantId, AppPlatform platform) {
        return findByPlatform(tenantId, platform).length;
    }

    Device[] filterByPlatform(Device[] devices, AppPlatform platform) {
        return devices.filter!(d => d.platform == platform).array;
    }

    Device[] findByPlatform(TenantId tenantId, AppPlatform platform) {
        return filterByPlatform(find(tenantId), platform);
    }

    void removeByPlatform(TenantId tenantId, AppPlatform platform) {
        findByPlatform(tenantId, platform).each!(e => remove(e));
    }

    size_t countByGroup(TenantId tenantId, string groupName) {
        return findByGroup(tenantId, groupName).length;
    }

    Device[] filterByGroup(Device[] devices, string groupName) {
        return devices.filter!(d => d.groupName == groupName).array;
    }

    Device[] findByGroup(TenantId tenantId, string groupName) {
        return filterByGroup(find(tenantId), groupName);
    }

    void removeByGroup(TenantId tenantId, string groupName) {
        findByGroup(tenantId, groupName).each!(e => remove(e));
    }

}
