/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.user_sessions;

import uim.platform.mobile.domain.entities.user_session;
import uim.platform.mobile.domain.types;

interface UserSessionRepository : ITenantRepository!(UserSession, UserSessionId) {

  size_t countByUser(string userId);
  UserSession[] findByUser(string userId);
  void removeByUser(string userId);

  size_t countByDevice(DeviceRegistrationId deviceId);
  UserSession[] findByDevice(DeviceRegistrationId deviceId);
  void removeByDevice(DeviceRegistrationId deviceId);

  size_t countByApp(MobileAppId appId);
  UserSession[] findByApp(MobileAppId appId);
  void removeByApp(MobileAppId appId);

  size_t countActive(MobileAppId appId);
  UserSession[] findActive(MobileAppId appId);
  void removeActive(MobileAppId appId);

}
