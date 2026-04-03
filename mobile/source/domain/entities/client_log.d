/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.client_log;

import uim.platform.mobile.domain.types;

/// A log entry uploaded from a mobile client.
struct ClientLog
{
  ClientLogId id;
  MobileAppId appId;
  TenantId tenantId;
  string userId;
  string deviceId;
  LogSeverity severity = LogSeverity.info;
  string message;
  string source; // module or class
  string stackTrace; // for error/crash logs
  string appVersion;
  MobilePlatform platform;
  string osVersion;
  string[string] context; // additional context
  long timestamp;
  long uploadedAt;
}
