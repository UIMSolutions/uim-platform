/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.user_sessions;

import uim.platform.mobile.domain.entities.user_session;
import uim.platform.mobile.domain.types;

interface UserSessionRepository {
  UserSession findById(UserSessionId id);
  UserSession[] findByUser(string userId);
  UserSession[] findByDevice(DeviceRegistrationId deviceId);
  UserSession[] findByApp(MobileAppId appId);
  UserSession[] findActive(MobileAppId appId);
  UserSession[] findByTenant(TenantId tenantId);
  void save(UserSession session);
  void update(UserSession session);
  void remove(UserSessionId id);
  size_t countActive(MobileAppId appId);
  size_t countByTenant(TenantId tenantId);
}
