/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.device_registration;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:

struct DeviceRegistration {
  mixin TenantEntity!(DeviceRegistrationId);

  MobileAppId appId;
  string deviceModel;
  string osVersion;
  string appVersion;
  AppPlatform platform;
  DeviceStatus status;
  UserId userId;
  string deviceToken;    // unique device identifier
  long lastConnectedAt;
  long registeredAt;
  
  Json toJson() const {
      return entityToJson
          .set("appId", appId.value)
          .set("deviceModel", deviceModel)
          .set("osVersion", osVersion)
          .set("appVersion", appVersion)
          .set("platform", platform.to!string)
          .set("status", status.to!string)
          .set("userId", userId)
          .set("deviceToken", deviceToken)
          .set("lastConnectedAt", lastConnectedAt)
          .set("registeredAt", registeredAt);
  }
}
