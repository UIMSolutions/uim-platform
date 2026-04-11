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

class MemoryDeviceRegistrationRepository : DeviceRegistrationRepository {
  private DeviceRegistration[DeviceRegistrationId] store;

  DeviceRegistration findById(DeviceRegistrationId id) {
    if (auto p = id in store)
      return *p;
    return DeviceRegistration.init;
  }

  DeviceRegistration findByDeviceToken(string deviceToken) {
    foreach (r; store) {
      if (r.deviceToken == deviceToken)
        return r;
    }
    return DeviceRegistration.init;
  }

  DeviceRegistration[] findByApp(MobileAppId appId) {
    return store.values.filter!(r => r.appId == appId).array;
  }

  DeviceRegistration[] findByUser(string userId) {
    return store.values.filter!(r => r.userId == userId).array;
  }

  DeviceRegistration[] findByTenant(TenantId tenantId) {
    return store.values.filter!(r => r.tenantId == tenantId).array;
  }

  void save(DeviceRegistration reg) {
    store[reg.id] = reg;
  }

  void update(DeviceRegistration reg) {
    store[reg.id] = reg;
  }

  void remove(DeviceRegistrationId id) {
    store.remove(id);
  }

  size_t countByApp(MobileAppId appId) {
    return store.values.filter!(r => r.appId == appId).array.length;
  }

  size_t countByTenant(TenantId tenantId) {
    return store.values.filter!(r => r.tenantId == tenantId).array.length;
  }
}
