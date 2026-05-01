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

class MemoryUsageReportRepository : TenantRepository!(UsageReport, UsageReportId), UsageReportRepository {
  
  size_t countByMetricType(MobileAppId appId, MetricType metricType) {
    return findByMetricType(appId, metricType).length;
  }

  UsageReport[] filterByMetricType(UsageReport[] reports, MetricType metricType) {
    return reports.filter!(r => r.metricType == metricType).array;
  }
  UsageReport[] findByMetricType(MobileAppId appId, MetricType metricType) {
    return filterByMetricType(findByApp(appId), metricType);
  }
  void removeByMetricType(MobileAppId appId, MetricType metricType) {
    findByMetricType(appId, metricType).each!(r => remove(r));
  }

  size_t countByApp(MobileAppId appId) {
    return findByApp(appId).length;
  } 
  UsageReport[] filterByApp(UsageReport[] reports, MobileAppId appId) {
    return reports.filter!(r => r.appId == appId).array;
  }
  UsageReport[] findByApp(MobileAppId appId) {
    return filterByApp(findAll().array, appId);
  }
  void removeByApp(MobileAppId appId) {
    findByApp(appId).each!(r => remove(r));
  }

  size_t countByDevice(DeviceRegistrationId deviceId) {
    return findByDevice(deviceId).length;
  }
  UsageReport[] filterByDevice(UsageReport[] reports, DeviceRegistrationId deviceId) {
    return reports.filter!(r => r.deviceId == deviceId).array;
  }
  UsageReport[] findByDevice(DeviceRegistrationId deviceId) {
    return filterByDevice(findAll().array, deviceId);
  }
  void removeByDevice(DeviceRegistrationId deviceId) {
    findByDevice(deviceId).each!(r => remove(r));
  }

  size_t countByUser(string userId) {
    return findByUser(userId).length;
  }
  UsageReport[] filterByUser(UsageReport[] reports, string userId) {
    return reports.filter!(r => r.userId == userId).array;
  }
  UsageReport[] findByUser(string userId) {
    return filterByUser(findAll().array, userId);
  }

  UsageReport[] findByMetricType(MobileAppId appId, MetricType metricType) {
    return filterByMetricType(findByApp(appId), metricType);
  }
  void removeByMetricType(MobileAppId appId, MetricType metricType) {
    findByMetricType(appId, metricType).each!(r => remove(r));
  }

}
