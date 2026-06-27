/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.push_registrations;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

interface PushRegistrationRepository : ITentRepository!(PushRegistration, PushRegistrationId) {

  bool existsByDeviceAndApp(TenantId tenantId, DeviceRegistrationId deviceId, MobileAppId appId);
  PushRegistration findByDeviceAndApp(TenantId tenantId, DeviceRegistrationId deviceId, MobileAppId appId);
  void removeByDeviceAndApp(TenantId tenantId, DeviceRegistrationId deviceId, MobileAppId appId);

  size_t countByApp(TenantId tenantId, MobileAppId appId);
  PushRegistration[] findByApp(TenantId tenantId, MobileAppId appId);
  void removeByApp(TenantId tenantId, MobileAppId appId);

  size_t countByTopic(TenantId tenantId, MobileAppId appId, string topic);
  PushRegistration[] findByTopic(TenantId tenantId, MobileAppId appId, string topic);
  void removeByTopic(TenantId tenantId, MobileAppId appId, string topic);

}
