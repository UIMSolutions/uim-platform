/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.device_registration_repository;

import uim.platform.mobile.domain.entities.device_registration;
import uim.platform.mobile.domain.types;

/// Port: outgoing — device registration persistence.
interface DeviceRegistrationRepository
{
  DeviceRegistration findById(DeviceRegistrationId id);
  DeviceRegistration[] findByApp(MobileAppId appId);
  DeviceRegistration[] findByUser(MobileAppId appId, string userId);
  DeviceRegistration[] findByPlatform(MobileAppId appId, MobilePlatform platform);
  DeviceRegistration[] findByStatus(MobileAppId appId, DeviceStatus status);
  DeviceRegistration findByPushToken(string pushToken);
  void save(DeviceRegistration reg);
  void update(DeviceRegistration reg);
  void remove(DeviceRegistrationId id);
}
