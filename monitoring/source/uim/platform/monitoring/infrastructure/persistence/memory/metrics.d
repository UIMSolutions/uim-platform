/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.infrastructure.persistence.memory.metrics;

// import uim.platform.monitoring.domain.types;
// import uim.platform.monitoring.domain.entities.metric;
// import uim.platform.monitoring.domain.ports.repositories.metrics;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class MemoryMetricRepository : TenantRepository!(Metric, MetricId), MetricRepository {

  Metric findByName(TenantId tenantId, string metricName) {
    return findByTenant(tenantId).filter!(m => m.name == metricName).array[0];
  }
  
  size_t countByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return findByResource(tenantId, resourceId).length;
  }

  Metric[] filterByResource(Metric[] metrics, MonitoredResourceId resourceId) {
    return metrics.filter!(m => m.resourceId == resourceId).array;
  }

  Metric[] findByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return filterByResource(findByTenant(TenantId(tenantId)), resourceId);
  }

  void removeByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    findByResource(tenantId, resourceId).each!(m => remove(m));
  }

  size_t countByName(TenantId tenantId, string metricName) {
    return findByName(tenantId, metricName).length;
  }

  Metric[] filterByName(Metric[] metrics, string metricName) {
    return metrics.filter!(m => m.name == metricName).array;
  }

  Metric[] findByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return filterByResource(findByTenant(tenantId), resourceId);
  }

  void removeByName(TenantId tenantId, string metricName) {
    findByName(tenantId, metricName).each!(m => remove(m));
  }

  size_t countByResourceAndName(TenantId tenantId, MonitoredResourceId resourceId, string metricName) {
    return findByResourceAndName(tenantId, resourceId, metricName).length;
  }

  Metric[] filterByResourceAndName(Metric[] metrics, MonitoredResourceId resourceId, string metricName) {
    return metrics.filter!(m => m.resourceId == resourceId && m.name == metricName).array;
  }

  Metric[] findByResourceAndName(TenantId tenantId, MonitoredResourceId resourceId, string metricName) {
    return filterByResourceAndName(findByTenant(tenantId), resourceId, metricName);
  }

  void removeByResourceAndName(TenantId tenantId, MonitoredResourceId resourceId, string metricName) {
    findByResourceAndName(tenantId, resourceId, metricName).each!(m => remove(m));
  }

  size_t countInTimeRange(TenantId tenantId, MonitoredResourceId resourceId, string metricName, long startTime, long endTime) {
    return findInTimeRange(tenantId, resourceId, metricName, startTime, endTime).length;
  }

  Metric[] filterInTimeRange(Metric[] metrics, MonitoredResourceId resourceId, string metricName, long startTime, long endTime) {
    return metrics.filter!(m => m.resourceId == resourceId && m.name == metricName && m.timestamp >= startTime && m
        .timestamp <= endTime).array;
  }

  Metric[] findByName(TenantId tenantId, string metricName) {
    return findByName(TenantId(tenantId), metricName);
  }

  void removeInTimeRange(TenantId tenantId, MonitoredResourceId resourceId, string metricName, long startTime, long endTime) {
    findInTimeRange(tenantId, resourceId, metricName, startTime, endTime).each!(m => remove(m));
  }

  size_t countByResourceAndName(TenantId tenantId, MonitoredResourceId resourceId, string metricName) {
    return findByResourceAndName(tenantId, resourceId, metricName).length;
  }

  Metric[] filterByResourceAndName(Metric[] metrics, MonitoredResourceId resourceId, string metricName) {
    return metrics.filter!(m => m.tenantId == tenantId && m.resourceId == resourceId && m.name == metricName)
      .array;
  }

  Metric[] findByResourceAndName(TenantId tenantId, MonitoredResourceId resourceId, string metricName) {
    return findByResource(tenantId, resourceId).filter!(m => m.name == metricName).array;
  }

  void removeByResourceAndName(TenantId tenantId, MonitoredResourceId resourceId, string metricName) {
    findByResourceAndName(tenantId, resourceId, metricName).each!(m => remove(m));
  }

  size_t countInTimeRange(TenantId tenantId, MonitoredResourceId resourceId, string metricName, long startTime, long endTime) {
    return findInTimeRange(tenantId, resourceId, metricName, startTime, endTime).length;
  }

  Metric[] filterInTimeRange(Metric[] metrics, MonitoredResourceId resourceId, string metricName, long startTime, long endTime) {
    return metrics.filter!(m => m.resourceId == resourceId && m.name == metricName && m.timestamp >= startTime && m
        .timestamp <= endTime).array;
  }

  Metric[] findInTimeRange(TenantId tenantId, MonitoredResourceId resourceId,
    string metricName, long startTime, long endTime) {
    return findByResourceAndName(tenantId, resourceId, metricName).filter!(
      m => m.timestamp >= startTime && m.timestamp <= endTime).array;
  }

  void removeInTimeRange(TenantId tenantId, MonitoredResourceId resourceId, string metricName, long startTime, long endTime) {
    findInTimeRange(tenantId, resourceId, metricName, startTime, endTime).each!(m => remove(m));
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    if (!existsByTenant(tenantId))
      return;

    auto metrics = findByTenant(tenantId).assocArray!(m => m.id);
    foreach (id, metric; metrics) {
      if (metric.timestamp < beforeTimestamp) {
        metrics.removeById(id);
      }
    }
    store[tenantId] = metrics;
  }
}
