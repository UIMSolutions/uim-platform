/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.ports.repositories.devices;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface IDeviceRepository : ITenantRepository!(Device, DeviceId) {

    size_t countByStatus(TenantId tenantId, DeviceStatus status);
    Device[] findByStatus(TenantId tenantId, DeviceStatus status);
    void removeByStatus(TenantId tenantId, DeviceStatus status);

    size_t countByMobileApplication(TenantId tenantId, MobileApplicationId appId);
    Device[] findByMobileApplication(TenantId tenantId, MobileApplicationId appId);
    void removeByMobileApplication(TenantId tenantId, MobileApplicationId appId);

    size_t countByPlatform(TenantId tenantId, AppPlatform platform);
    Device[] findByPlatform(TenantId tenantId, AppPlatform platform);
    void removeByPlatform(TenantId tenantId, AppPlatform platform);

    size_t countByGroup(TenantId tenantId, string groupName);
    Device[] findByGroup(TenantId tenantId, string groupName);
    void removeByGroup(TenantId tenantId, string groupName);
    
}
