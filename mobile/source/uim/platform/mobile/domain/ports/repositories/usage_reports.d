/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.ports.repositories.usage_reports;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:

interface UsageReportRepository : ITenantRepository!(UsageReport, UsageReportId) {

  size_t countByApp(TenantId tenantId, MobileAppId appId);
  UsageReport[] findByApp(TenantId tenantId, MobileAppId appId);
  void removeByApp(TenantId tenantId, MobileAppId appId);

  size_t countByDevice(TenantId tenantId, DeviceRegistrationId deviceId);
  UsageReport[] findByDevice(TenantId tenantId, DeviceRegistrationId deviceId);
  void removeByDevice(TenantId tenantId, DeviceRegistrationId deviceId);

  size_t countByUser(TenantId tenantId, UserId userId);
  UsageReport[] findByUser(TenantId tenantId, UserId userId);
  void removeByUser(TenantId tenantId, UserId userId);

  size_t countByMetricType(TenantId tenantId, MobileAppId appId, MetricType metricType);
  UsageReport[] findByMetricType(TenantId tenantId, MobileAppId appId, MetricType metricType);
  void removeByMetricType(TenantId tenantId, MobileAppId appId, MetricType metricType);

}
