/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.device_registration;

import uim.platform.mobile.domain.entities.device_registration;
import uim.platform.mobile.domain.ports.repositories.device_registrations;
import uim.platform.mobile.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryDeviceRegistrationRepository : TenantRepository!(DeviceRegistration, DeviceRegistrationId), DeviceRegistrationRepository {

  bool existsByDeviceToken(string deviceToken) {
    return store.any!(r => r.deviceToken == deviceToken);
  }

  DeviceRegistration findByDeviceToken(string deviceToken) {
    foreach (r; findAll) {
      if (r.deviceToken == deviceToken)
        return r;
    }
    return DeviceRegistration.init;
  }

  size_t countByApp(MobileAppId appId) {
    return findByApp(appId).length;
  }
  DeviceRegistration[] filterByApp(DeviceRegistration[] registrations, MobileAppId appId) {
    return registrations.filter!(r => r.appId == appId).array;
  }
  DeviceRegistration[] findByApp(MobileAppId appId) {
    return findAll().filter!(r => r.appId == appId).array;
  }
  void removeByApp(MobileAppId appId) {
    findByApp(appId).each!(r => remove(r));
  }

  size_t countByUser(string userId) {
    return findByUser(userId).length;
  }
  DeviceRegistration[] filterByUser(DeviceRegistration[] registrations, string userId) {
    return registrations.filter!(r => r.userId == userId).array;
  }
  DeviceRegistration[] findByUser(string userId) {
    return findAll().filter!(r => r.userId == userId).array;
  }
  void removeByUser(string userId) {
    findByUser(userId).each!(r => remove(r));
  }

}
