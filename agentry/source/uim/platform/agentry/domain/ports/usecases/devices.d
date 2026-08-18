/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.tests.usecases.manage.devices;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface IManageDevicesUseCase {

    Device[] listDevices(TenantId tenantId);
    Device getDevice(TenantId tenantId, DeviceId id);
    UsecaseResult enrollDevice(DeviceDTO dto);
    UsecaseResult updateDevice(DeviceDTO dto);
    UsecaseResult removeDevice(TenantId tenantId, DeviceId id);

    Device[] listByMobileApplication(TenantId tenantId, MobileApplicationId appId);
    Device[] listByStatus(TenantId tenantId, DeviceStatus status);
    Device[] listByGroup(TenantId tenantId, string groupName);

}
