/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.user_sessions;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

interface UserSessionRepository : ITentRepository!(UserSession, UserSessionId) {

  size_t countByUser(TenantId tenantId, UserId userId);
  UserSession[] findByUser(TenantId tenantId, UserId userId);
  void removeByUser(TenantId tenantId, UserId userId);

  size_t countByDevice(TenantId tenantId, DeviceRegistrationId deviceId);
  UserSession[] findByDevice(TenantId tenantId, DeviceRegistrationId deviceId);
  void removeByDevice(TenantId tenantId, DeviceRegistrationId deviceId);

  size_t countByApp(TenantId tenantId, MobileAppId appId);
  UserSession[] findByApp(TenantId tenantId, MobileAppId appId);
  void removeByApp(TenantId tenantId, MobileAppId appId);

  size_t countActive(TenantId tenantId, MobileAppId appId);
  UserSession[] findActive(TenantId tenantId, MobileAppId appId);
  void removeActive(TenantId tenantId, MobileAppId appId);

}
