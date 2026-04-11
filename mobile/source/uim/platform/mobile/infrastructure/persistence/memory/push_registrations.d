/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.push_registration;

import uim.platform.mobile.domain.entities.push_registration;
import uim.platform.mobile.domain.ports.repositories.push_registrations;
import uim.platform.mobile.domain.types;

import std.algorithm : canFind, filter;
import std.array : array;

class MemoryPushRegistrationRepository : PushRegistrationRepository {
  private PushRegistration[PushRegistrationId] store;

  PushRegistration findById(PushRegistrationId id) {
    if (auto p = id in store)
      return *p;
    return PushRegistration.init;
  }

  PushRegistration findByDeviceAndApp(DeviceRegistrationId deviceId, MobileAppId appId) {
    foreach (r; store) {
      if (r.deviceId == deviceId && r.appId == appId)
        return r;
    }
    return PushRegistration.init;
  }

  PushRegistration[] findByApp(MobileAppId appId) {
    return store.values.filter!(r => r.appId == appId).array;
  }

  PushRegistration[] findByTopic(MobileAppId appId, string topic) {
    PushRegistration[] result;
    foreach (r; store) {
      if (r.appId == appId && r.topics.canFind(topic))
        result ~= r;
    }
    return result;
  }

  PushRegistration[] findByTenant(TenantId tenantId) {
    return store.values.filter!(r => r.tenantId == tenantId).array;
  }

  void save(PushRegistration reg) {
    store[reg.id] = reg;
  }

  void update(PushRegistration reg) {
    store[reg.id] = reg;
  }

  void remove(PushRegistrationId id) {
    store.remove(id);
  }

  size_t countByApp(MobileAppId appId) {
    return cast(long) store.values.filter!(r => r.appId == appId).array.length;
  }
}
