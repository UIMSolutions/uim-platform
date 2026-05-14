/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.device_registration;

// import uim.platform.mobile.domain.entities.device_registration;
// import uim.platform.mobile.domain.ports.repositories.device_registrations;
// import uim.platform.mobile.domain.types;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:

class MemoryDeviceRegistrationRepository : TenantRepository!(DeviceRegistration, DeviceRegistrationId), DeviceRegistrationRepository {

  bool existsByDeviceToken(TenantId tenantId, string deviceToken) {
    return store.any!(r => r.deviceToken == deviceToken);
  }

  DeviceRegistration findByDeviceToken(TenantId tenantId, string deviceToken) {
    foreach (r; findAll) {
      if (r.deviceToken == deviceToken)
        return r;
    }
    return DeviceRegistration.init;
  }

  size_t countByApp(TenantId tenantId, MobileAppId appId) {
    return findByApp(tenantId, appId).length;
  }

  DeviceRegistration[] findByApp(TenantId tenantId, MobileAppId appId) {
    return findAll().filter!(r => r.appId == appId).array;
  }

  void removeByApp(TenantId tenantId, MobileAppId appId) {
    findByApp(tenantId, appId).each!(r => remove(r));
  }

  size_t countByUser(TenantId tenantId, UserId userId) {
    return findByUser(tenantId, userId).length;
  }

  DeviceRegistration[] filterByUser(DeviceRegistration[] registrations, UserId userId) {
    return registrations.filter!(r => r.userId == userId).array;
  }

  DeviceRegistration[] findByUser(TenantId tenantId, UserId userId) {
    return findAll().filter!(r => r.userId == userId).array;
  }

  void removeByUser(TenantId tenantId, UserId userId) {
    findByUser(tenantId, userId).each!(r => remove(r));
  }

}
