/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.repositories.devices;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface IDeviceRepository : ITenantRepository!(Device, DeviceId) {
    Device[] findByMobileApplication(TenantId tenantId, MobileApplicationId appId);
    Device[] findByStatus(TenantId tenantId, DeviceStatus status);
    Device[] findByPlatform(TenantId tenantId, AppPlatform platform);
    Device[] findByGroup(TenantId tenantId, string groupName);
    size_t countByStatus(TenantId tenantId, DeviceStatus status);
}
