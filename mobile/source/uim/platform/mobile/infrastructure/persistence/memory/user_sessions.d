/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.user_sessions;
// import uim.platform.mobile.domain.entities.user_session;
// import uim.platform.mobile.domain.ports.repositories.user_sessions;


import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

class MemoryUserSessionRepository : TenantRepository!(UserSession, UserSessionId), UserSessionRepository {
  
  size_t countByUser(TenantId tenantId, UserId userId) {
    return findByUser(tenantId, userId).length;
  }
  UserSession[] findByUser(TenantId tenantId, UserId userId) {
    return findByTenant(tenantId).filter!(s => s.tenantId == tenantId && s.userId == userId).array;
  }
  void removeByUser(TenantId tenantId, UserId userId) {
    findByUser(tenantId, userId).each!(s => store.remove(s));
  }

  size_t countByDevice(TenantId tenantId, DeviceRegistrationId deviceId) {
    return findByDevice(tenantId, deviceId).length;
  }
  UserSession[] findByDevice(TenantId tenantId, DeviceRegistrationId deviceId) {
    return findByTenant(tenantId).filter!(s => s.tenantId == tenantId && s.deviceId == deviceId).array;
  }
  void removeByDevice(TenantId tenantId, DeviceRegistrationId deviceId) {
    findByDevice(tenantId, deviceId).each!(s => store.remove(s));
  }

  size_t countByApp(TenantId tenantId, MobileAppId appId) {
    return findByApp(tenantId, appId).length;
  }
  UserSession[] findByApp(TenantId tenantId, MobileAppId appId) {
    return findByTenant(tenantId).filter!(s => s.tenantId == tenantId && s.appId == appId).array;
  }
  void removeByApp(TenantId tenantId, MobileAppId appId) {
    findByApp(tenantId, appId).each!(s => store.remove(s));
  }

  size_t countActive(TenantId tenantId, MobileAppId appId) {
    return findActive(tenantId, appId).length;
  }
  UserSession[] filterActive(UserSession[] sessions, MobileAppId appId) {
    return sessions.filter!(s => s.appId == appId && s.status == SessionStatus.active).array;
  }
  UserSession[] findActive(TenantId tenantId, MobileAppId appId) {
    return filterActive(findByApp(tenantId, appId), appId);
  }
  void removeActive(TenantId tenantId, MobileAppId appId) {
    findActive(tenantId, appId).each!(s => store.remove(s));
  }

}
