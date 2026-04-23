/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.device_registrations;

import uim.platform.mobile.domain.entities.device_registration;
import uim.platform.mobile.domain.types;

interface DeviceRegistrationRepository : ITenantRepository!(DeviceRegistration, DeviceRegistrationId) {

  bool existsByDeviceToken(string deviceToken);
  DeviceRegistration findByDeviceToken(string deviceToken);
  void removeByDeviceToken(string deviceToken);

  size_t countByApp(MobileAppId appId);
  DeviceRegistration[] findByApp(MobileAppId appId);
  void removeByApp(MobileAppId appId);

  size_t countByUser(string userId);
  DeviceRegistration[] findByUser(string userId);
  void removeByUser(string userId);

}
