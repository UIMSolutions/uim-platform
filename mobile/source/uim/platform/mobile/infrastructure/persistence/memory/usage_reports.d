/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.usage_report;

// import uim.platform.mobile.domain.entities.usage_report;
// import uim.platform.mobile.domain.ports.repositories.usage_reports;
// import uim.platform.mobile.domain.types;

import uim.platform.mobile;

mixin(Showmodule!());

@safe:

class MemoryUsageReportRepository : TenantRepository!(UsageReport, UsageReportId), UsageReportRepository {
  
  size_t countByMetricType(TenantId tenantId, MobileAppId appId, MetricType metricType) {
    return findByMetricType(tenantId, appId, metricType).length;
  }

  UsageReport[] filterByMetricType(UsageReport[] reports, MetricType metricType) {
    return reports.filter!(r => r.metricType == metricType).array;
  }
  UsageReport[] findByMetricType(TenantId tenantId, MobileAppId appId, MetricType metricType) {
    return filterByMetricType(findByApp(tenantId, appId), metricType);
  }
  void removeByMetricType(TenantId tenantId, MobileAppId appId, MetricType metricType) {
    findByMetricType(tenantId, appId, metricType).each!(r => remove(r));
  }

  size_t countByApp(TenantId tenantId, MobileAppId appId) {
    return findByApp(tenantId, appId).length;
  } 
  UsageReport[] filterByApp(UsageReport[] reports, MobileAppId appId) {
    return reports.filter!(r => r.appId == appId).array;
  }
  UsageReport[] findByApp(TenantId tenantId, MobileAppId appId) {
    return filterByApp(findAll().array, appId);
  }
  void removeByApp(TenantId tenantId, MobileAppId appId) {
    findByApp(tenantId, appId).each!(r => remove(r));
  }

  size_t countByDevice(TenantId tenantId, DeviceRegistrationId deviceId) {
    return findByDevice(tenantId, deviceId).length;
  }
  UsageReport[] filterByDevice(UsageReport[] reports, DeviceRegistrationId deviceId) {
    return reports.filter!(r => r.deviceId == deviceId).array;
  }
  UsageReport[] findByDevice(TenantId tenantId, DeviceRegistrationId deviceId) {
    return filterByDevice(findAll().array, deviceId);
  }
  void removeByDevice(TenantId tenantId, DeviceRegistrationId deviceId) {
    findByDevice(tenantId, deviceId).each!(r => remove(r));
  }

  size_t countByUser(TenantId tenantId, UserId userId) {
    return findByUser(tenantId, userId).length;
  }
  UsageReport[] filterByUser(UsageReport[] reports, UserId userId) {
    return reports.filter!(r => r.userId == userId).array;
  }
  UsageReport[] findByUser(TenantId tenantId, UserId userId) {
    return filterByUser(findAll().array, userId);
  }

  UsageReport[] findByMetricType(TenantId tenantId, MobileAppId appId, MetricType metricType) {
    return filterByMetricType(findByApp(tenantId, appId), metricType);
  }
  void removeByMetricType(TenantId tenantId, MobileAppId appId, MetricType metricType) {
    findByMetricType(tenantId, appId, metricType).each!(r => remove(r));
  }

}
