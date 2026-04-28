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

class MemoryPushRegistrationRepository : TenantRepository!(PushRegistration, PushRegistrationId), PushRegistrationRepository {
  
  bool existsByDeviceAndApp(DeviceRegistrationId deviceId, MobileAppId appId) {
    return findByDeviceAndApp(deviceId, appId).id != PushRegistrationId.init;
  }

  PushRegistration findByDeviceAndApp(DeviceRegistrationId deviceId, MobileAppId appId) {
    foreach (r; findAll) {
      if (r.deviceId == deviceId && r.appId == appId)
        return r;
    }
    return PushRegistration.init;
  }

  size_t countByApp(MobileAppId appId) {
    return findByApp(appId).length;
  }
  PushRegistration[] filterByApp(PushRegistration[] registrations, MobileAppId appId) {
    return registrations.filter!(r => r.appId == appId).array;
  }
  PushRegistration[] findByApp(MobileAppId appId) {
    return filterByApp(findAll()().values.array, appId);
  }
  void removeByApp(MobileAppId appId) {
    findByApp(appId).each!(r => remove(r));
  }

  size_t countByDevice(DeviceRegistrationId deviceId) {
    return findByDevice(deviceId).length;
  }
  PushRegistration[] filterByDevice(PushRegistration[] registrations, DeviceRegistrationId deviceId) {
    return registrations.filter!(r => r.deviceId == deviceId).array;
  }
  PushRegistration[] findByDevice(DeviceRegistrationId deviceId) {
    return filterByDevice(findAll()().values.array, deviceId);
  }
  void removeByDevice(DeviceRegistrationId deviceId) {
    findByDevice(deviceId).each!(r => remove(r));
  }

  size_t countByTopic(MobileAppId appId, string topic) {
    return findByTopic(appId, topic).length;
  }
  PushRegistration[] filterByTopic(PushRegistration[] registrations, string topic) {
    return registrations.filter!(r => r.topics.canFind(topic)).array;
  }
  PushRegistration[] findByTopic(MobileAppId appId, string topic) {
    return filterByTopic(findByApp(appId), topic);
  }

}
