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

class MemoryUserSessionRepository : UserSessionRepository {
  private UserSession[UserSessionId] store;

  UserSession findById(UserSessionId id) {
    if (auto p = id in store)
      return *p;
    return UserSession.init;
  }

  UserSession[] findByUser(string userId) {
    return store.values.filter!(s => s.userId == userId).array;
  }

  UserSession[] findByDevice(DeviceRegistrationId deviceId) {
    return store.values.filter!(s => s.deviceId == deviceId).array;
  }

  UserSession[] findByApp(MobileAppId appId) {
    return store.values.filter!(s => s.appId == appId).array;
  }

  UserSession[] findActive(MobileAppId appId) {
    return store.values.filter!(s => s.appId == appId && s.status == SessionStatus.active).array;
  }

  UserSession[] findByTenant(TenantId tenantId) {
    return store.values.filter!(s => s.tenantId == tenantId).array;
  }

  void save(UserSession session) {
    store[session.id] = session;
  }

  void update(UserSession session) {
    store[session.id] = session;
  }

  void remove(UserSessionId id) {
    store.remove(id);
  }

  size_t countActive(MobileAppId appId) {
    return store.values.filter!(s => s.appId == appId && s.status == SessionStatus.active).array.length;
  }

  size_t countByTenant(TenantId tenantId) {
    return store.values.filter!(s => s.tenantId == tenantId).array.length;
  }
}
