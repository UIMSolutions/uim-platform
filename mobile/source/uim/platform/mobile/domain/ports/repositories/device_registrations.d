/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.device_registration_repository;

import uim.platform.mobile.domain.entities.device_registration;
import uim.platform.mobile.domain.types;

interface DeviceRegistrationRepository {
  DeviceRegistration findById(DeviceRegistrationId id);
  DeviceRegistration findByDeviceToken(string deviceToken);
  DeviceRegistration[] findByApp(MobileAppId appId);
  DeviceRegistration[] findByUser(string userId);
  DeviceRegistration[] findByTenant(TenantId tenantId);
  void save(DeviceRegistration reg);
  void update(DeviceRegistration reg);
  void remove(DeviceRegistrationId id);
  long countByApp(MobileAppId appId);
  long countByTenant(TenantId tenantId);
}
