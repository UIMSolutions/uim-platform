/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.usage_event;

import uim.platform.mobile.domain.types;

/// An analytics event from a mobile app.
struct UsageEvent
{
  UsageEventId id;
  MobileAppId appId;
  TenantId tenantId;
  string userId;
  string deviceId;
  UsageEventType eventType;
  string eventName; // e.g. screen name, action name
  string screenName;
  string appVersion;
  MobilePlatform platform;
  long durationMs; // for timed events
  string[string] properties; // custom event properties
  // Performance data (for performanceMetric events)
  double responseTimeMs;
  long memoryUsageBytes;
  double cpuUsagePercent;
  double batteryLevel;
  string networkType; // wifi, cellular, offline
  long timestamp;
}
