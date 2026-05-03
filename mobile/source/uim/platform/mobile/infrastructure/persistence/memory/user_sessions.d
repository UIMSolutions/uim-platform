/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.user_session;

import uim.platform.mobile.domain.entities.user_session;
import uim.platform.mobile.domain.ports.repositories.user_sessions;
import uim.platform.mobile.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryUserSessionRepository : TenantRepository!(UserSession, UserSessionId), UserSessionRepository {
  
  size_t countByUser(string userId) {
    return findByUser(userId).length;
  }
  UserSession[] findByUser(string userId) {
    return findAll().filter!(s => s.userId == userId).array;
  }
  void removeByUser(string userId) {
    findByUser(userId).each!(s => store.remove(s));
  }

  size_t countByDevice(DeviceRegistrationId deviceId) {
    return findByDevice(deviceId).length;
  }
  UserSession[] findByDevice(DeviceRegistrationId deviceId) {
    return findAll().filter!(s => s.deviceId == deviceId).array;
  }
  void removeByDevice(DeviceRegistrationId deviceId) {
    findByDevice(deviceId).each!(s => store.remove(s));
  }

  size_t countByApp(MobileAppId appId) {
    return findByApp(appId).length;
  }
  UserSession[] findByApp(MobileAppId appId) {
    return findAll().filter!(s => s.appId == appId).array;
  }
  void removeByApp(MobileAppId appId) {
    findByApp(appId).each!(s => store.remove(s));
  }

  size_t countActive(MobileAppId appId) {
    return findActive(appId).length;
  }
  UserSession[] findActive(MobileAppId appId) {
    return findAll().filter!(s => s.appId == appId && s.status == SessionStatus.active).array;
  }
  void removeActive(MobileAppId appId) {
    findActive(appId).each!(s => store.remove(s));
  }

}
