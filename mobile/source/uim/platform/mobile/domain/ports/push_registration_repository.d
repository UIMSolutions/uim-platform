/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.push_registration_repository;

import uim.platform.mobile.domain.entities.push_registration;
import uim.platform.mobile.domain.types;

interface PushRegistrationRepository {
  PushRegistration findById(PushRegistrationId id);
  PushRegistration findByDeviceAndApp(DeviceRegistrationId deviceId, MobileAppId appId);
  PushRegistration[] findByApp(MobileAppId appId);
  PushRegistration[] findByTopic(MobileAppId appId, string topic);
  PushRegistration[] findByTenant(TenantId tenantId);
  void save(PushRegistration reg);
  void update(PushRegistration reg);
  void remove(PushRegistrationId id);
  long countByApp(MobileAppId appId);
}
