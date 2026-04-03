/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.user_session;

import uim.platform.mobile.domain.types;

struct UserSession {
  UserSessionId id;
  TenantId tenantId;
  MobileAppId appId;
  DeviceRegistrationId deviceId;
  string userId;
  SessionStatus status;
  string ipAddress;
  string userAgent;
  AppPlatform platform;
  string appVersion;
  long startedAt;
  long lastActivityAt;
  long expiresAt;
  long endedAt;
}
