/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.infrastructure.persistence.memory.usage_report;

import uim.platform.mobile.domain.entities.usage_report;
import uim.platform.mobile.domain.ports.repositories.usage_reports;
import uim.platform.mobile.domain.types;

import std.algorithm : filter;
import std.array : array;

class MemoryUsageReportRepository : UsageReportRepository {
  private UsageReport[UsageReportId] store;

  UsageReport findById(UsageReportId id) {
    if (auto p = id in store)
      return *p;
    return UsageReport.init;
  }

  UsageReport[] findByApp(MobileAppId appId) {
    return store.values.filter!(r => r.appId == appId).array;
  }

  UsageReport[] findByDevice(DeviceRegistrationId deviceId) {
    return store.values.filter!(r => r.deviceId == deviceId).array;
  }

  UsageReport[] findByUser(string userId) {
    return store.values.filter!(r => r.userId == userId).array;
  }

  UsageReport[] findByMetricType(MobileAppId appId, MetricType metricType) {
    return store.values.filter!(r => r.appId == appId && r.metricType == metricType).array;
  }

  UsageReport[] findByTenant(TenantId tenantId) {
    return store.values.filter!(r => r.tenantId == tenantId).array;
  }

  void save(UsageReport report) {
    store[report.id] = report;
  }

  void remove(UsageReportId id) {
    store.remove(id);
  }

  size_t countByApp(MobileAppId appId) {
    return cast(long) store.values.filter!(r => r.appId == appId).array.length;
  }

  size_t countByTenant(TenantId tenantId) {
    return cast(long) store.values.filter!(r => r.tenantId == tenantId).array.length;
  }
}
