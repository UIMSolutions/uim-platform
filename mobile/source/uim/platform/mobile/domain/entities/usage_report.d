/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.usage_report;

import uim.platform.mobile.domain.types;

struct UsageReport {
  UsageReportId id;
  TenantId tenantId;
  MobileAppId appId;
  DeviceRegistrationId deviceId;
  string userId;
  MetricType metricType;
  string metricKey;          // custom metric name
  string metricValue;        // metric value/data
  string sessionId;
  AppPlatform platform;
  string appVersion;
  long timestamp;
  long createdAt;
}
