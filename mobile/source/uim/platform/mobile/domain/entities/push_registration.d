/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.push_registration;

import uim.platform.mobile.domain.types;

struct PushRegistration {
  PushRegistrationId id;
  TenantId tenantId;
  MobileAppId appId;
  DeviceRegistrationId deviceId;
  PushProvider provider;
  string pushToken;       // provider-specific push token
  string[] topics;        // subscribed topics
  PushRegStatus status;
  long registeredAt;
  long updatedAt;
  long expiresAt;
}
