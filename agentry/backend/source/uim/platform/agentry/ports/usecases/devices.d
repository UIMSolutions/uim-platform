/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.ports.usecases.devices;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Driving port: enroll and manage mobile devices.
interface IManageDevicesUseCase {
  MobileDevice[] listDevices(TenantId tenantId);
  MobileDevice[] listByMobileApplication(TenantId tenantId, MobileApplicationId appId);
  MobileDevice[] listByStatus(TenantId tenantId, DeviceStatus status);
  MobileDevice[] listByGroup(TenantId tenantId, string groupName);
  MobileDevice getDevice(TenantId tenantId, DeviceId id);

  UsecaseResult enrollDevice(DeviceDTO dto);
  UsecaseResult updateDevice(DeviceDTO dto);
  /// Lifecycle change (enrolled → active ⇄ suspended → removed).
  UsecaseResult setDeviceStatus(TenantId tenantId, DeviceId id, DeviceStatus status, UserId by);
  UsecaseResult removeDevice(TenantId tenantId, DeviceId id);
}
