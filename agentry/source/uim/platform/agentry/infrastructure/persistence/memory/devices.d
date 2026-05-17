/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.infrastructure.persistence.memory.devices;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class MemoryDeviceRepository
    : TenantRepository!(Device, DeviceId), DeviceRepository {

    Device[] findByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return findByTenant(tenantId).filter!(d => d.mobileApplicationId == appId).array;
    }

    Device[] findByStatus(TenantId tenantId, DeviceStatus status) {
        return findByTenant(tenantId).filter!(d => d.status == status).array;
    }

    Device[] findByPlatform(TenantId tenantId, AppPlatform platform) {
        return findByTenant(tenantId).filter!(d => d.platform == platform).array;
    }

    Device[] findByGroup(TenantId tenantId, string groupName) {
        return findByTenant(tenantId).filter!(d => d.groupName == groupName).array;
    }

    size_t countByStatus(TenantId tenantId, DeviceStatus status) {
        return findByStatus(tenantId, status).length;
    }
}
