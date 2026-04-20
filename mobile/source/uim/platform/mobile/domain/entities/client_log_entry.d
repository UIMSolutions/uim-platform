/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.client_log_entry;

import uim.platform.mobile.domain.types;

struct ClientLogEntry {
  mixin TenantEntity!(ClientLogEntryId);

  MobileAppId appId;
  DeviceRegistrationId deviceId;
  string userId;
  LogLevel level;
  LogSource source;
  string message;
  string stackTrace;
  string metadata;          // JSON additional context
  AppPlatform platform;
  string appVersion;
  long timestamp;
  long uploadedAt;

  Json toJson() const {
    auto j = entityToJson
      .set("appId", appId.value)
      .set("deviceId", deviceId.value)
      .set("userId", userId)
      .set("level", level.toString())
      .set("source", source.toString())
      .set("message", message)
      .set("stackTrace", stackTrace)
      .set("metadata", metadata)
      .set("platform", platform.toString())
      .set("appVersion", appVersion)
      .set("timestamp", timestamp)
      .set("uploadedAt", uploadedAt);

    return j;
  }
}
