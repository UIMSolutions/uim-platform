/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.usage_reports;

import uim.platform.mobile.domain.entities.usage_report;
import uim.platform.mobile.domain.types;

interface UsageReportRepository : ITenantRepository!(UsageReport, UsageReportId) {

  size_t countByApp(MobileAppId appId);
  UsageReport[] findByApp(MobileAppId appId);
  void removeByApp(MobileAppId appId);

  size_t countByDevice(DeviceRegistrationId deviceId);
  UsageReport[] findByDevice(DeviceRegistrationId deviceId);
  void removeByDevice(DeviceRegistrationId deviceId);

  size_t countByUser(string userId);
  UsageReport[] findByUser(string userId);
  void removeByUser(string userId);

  size_t countByMetricType(MobileAppId appId, MetricType metricType);
  UsageReport[] findByMetricType(MobileAppId appId, MetricType metricType);
  void removeByMetricType(MobileAppId appId, MetricType metricType);

}
