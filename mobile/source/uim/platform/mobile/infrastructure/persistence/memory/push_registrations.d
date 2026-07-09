/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.push_registrations;
// import uim.platform.mobile.domain.entities.push_registration;
// import uim.platform.mobile.domain.ports.repositories.push_registrations;

// import std.algorithm : canFind, filter;
import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

class MemoryPushRegistrationRepository : TenantRepository!(PushRegistration, PushRegistrationId), PushRegistrationRepository {

  bool existsByDeviceAndApp(TenantId tenantId, DeviceRegistrationId deviceId, MobileAppId appId) {
    return findByDeviceAndApp(tenantId, deviceId, appId).id != PushRegistrationId.init;
  }

  PushRegistration findByDeviceAndApp(TenantId tenantId, DeviceRegistrationId deviceId, MobileAppId appId) {
    foreach (r; findByTenant(tenantId)) {
      if (r.deviceId == deviceId && r.appId == appId)
        return r;
    }
    return PushRegistration.init;
  }
  void removeByDeviceAndApp(TenantId tenantId, DeviceRegistrationId deviceId, MobileAppId appId) {
    foreach (r; findByTenant(tenantId)) {
      if (r.deviceId == deviceId && r.appId == appId)
        remove(r);
    }
  }

  size_t countByApp(TenantId tenantId, MobileAppId appId) {
    return findByApp(tenantId, appId).length;
  }

  PushRegistration[] filterByApp(PushRegistration[] registrations, MobileAppId appId) {
    return registrations.filter!(r => r.appId == appId).array;
  }
  PushRegistration[] findByApp(TenantId tenantId, MobileAppId appId) {
    return filterByApp(findByTenant(tenantId), appId);
  }

  void removeByApp(TenantId tenantId, MobileAppId appId) {
    findByApp(tenantId, appId).each!(r => remove(r));
  }

  size_t countByDevice(TenantId tenantId, DeviceRegistrationId deviceId) {
    return findByDevice(tenantId, deviceId).length;
  }

  PushRegistration[] filterByDevice(PushRegistration[] registrations, DeviceRegistrationId deviceId) {
    return registrations.filter!(r => r.deviceId == deviceId).array;
  }

  PushRegistration[] findByDevice(TenantId tenantId, DeviceRegistrationId deviceId) {
    return filterByDevice(findByTenant(tenantId), deviceId);
  }

  void removeByDevice(TenantId tenantId, DeviceRegistrationId deviceId) {
    findByDevice(tenantId, deviceId).each!(r => remove(r));
  }

  size_t countByTopic(TenantId tenantId, MobileAppId appId, string topic) {
    return findByTopic(tenantId, appId, topic).length;
  }

  PushRegistration[] filterByTopic(PushRegistration[] registrations, string topic) {
    return registrations.filter!(r => r.topics.canFind(topic)).array;
  }

  PushRegistration[] findByTopic(TenantId tenantId, MobileAppId appId, string topic) {
    return filterByTopic(findByApp(tenantId, appId), topic);
  }
  void removeByTopic(TenantId tenantId, MobileAppId appId, string topic) {
    findByTopic(tenantId, appId, topic).each!(r => remove(r));
  }

}
