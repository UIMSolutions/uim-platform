/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.device_registration;

import uim.platform.mobile.domain.types;

struct DeviceRegistration {
  DeviceRegistrationId id;
  TenantId tenantId;
  MobileAppId appId;
  string deviceModel;
  string osVersion;
  string appVersion;
  AppPlatform platform;
  DeviceStatus status;
  string userId;
  string deviceToken;    // unique device identifier
  long lastConnectedAt;
  long registeredAt;
  long updatedAt;
}
