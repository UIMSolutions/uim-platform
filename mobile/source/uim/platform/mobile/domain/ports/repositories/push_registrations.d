/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.push_registrations;

import uim.platform.mobile.domain.entities.push_registration;
import uim.platform.mobile.domain.types;

interface PushRegistrationRepository : ITenantRepository!(PushRegistration, PushRegistrationId) {

  bool existsByDeviceAndApp(DeviceRegistrationId deviceId, MobileAppId appId);
  PushRegistration findByDeviceAndApp(DeviceRegistrationId deviceId, MobileAppId appId);
  void findByDeviceAndApp(DeviceRegistrationId deviceId, MobileAppId appId);

  size_t countByApp(MobileAppId appId);
  PushRegistration[] findByApp(MobileAppId appId);
  void removeByApp(MobileAppId appId);

  size_t countByTopic(MobileAppId appId, string topic);
  PushRegistration[] findByTopic(MobileAppId appId, string topic);
  void removeByTopic(MobileAppId appId, string topic);

}
