/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.usage_report;

import uim.platform.mobile.domain.types;

struct UsageReport {
  mixin TenantEntity!(UsageReportId);

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

  Json toJson() const {
    auto j = entityToJson
      .set("appId", appId.value)
      .set("deviceId", deviceId.value)
      .set("userId", userId)
      .set("metricType", metricType)
      .set("metricKey", metricKey)
      .set("metricValue", metricValue)
      .set("sessionId", sessionId)
      .set("platform", platform)
      .set("appVersion", appVersion)
      .set("timestamp", timestamp);

    return j;
  }
}
