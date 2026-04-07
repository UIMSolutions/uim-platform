/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.infrastructure.persistence.memory.metric_repo;

import uim.platform.monitoring.domain.types;
import uim.platform.monitoring.domain.entities.metric;
import uim.platform.monitoring.domain.ports.repositories.metrics;

// import std.algorithm : filter;
// import std.array : array;

class MemoryMetricRepository : MetricRepository {
  private Metric[] store;

  Metric findById(MetricId id) {
    foreach (ref m; store)
      if (m.id == id)
        return m;
    return Metric.init;
  }

  Metric[] findByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return store.filter!(m => m.tenantId == tenantId && m.resourceId == resourceId).array;
  }

  Metric[] findByName(TenantId tenantId, string metricName) {
    return store.filter!(m => m.tenantId == tenantId && m.name == metricName).array;
  }

  Metric[] findByResourceAndName(TenantId tenantId, MonitoredResourceId resourceId,
      string metricName) {
    return store.filter!(m => m.tenantId == tenantId
        && m.resourceId == resourceId && m.name == metricName).array;
  }

  Metric[] findInTimeRange(TenantId tenantId, MonitoredResourceId resourceId,
      string metricName, long startTime, long endTime) {
    return store.filter!(m => m.tenantId == tenantId && m.resourceId == resourceId
        && m.name == metricName && m.timestamp >= startTime && m.timestamp <= endTime).array;
  }

  void save(Metric m) {
    store ~= m;
  }

  void saveAll(Metric[] metrics) {
    foreach (ref m; metrics)
      store ~= m;
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    store = store.filter!(m => !(m.tenantId == tenantId && m.timestamp < beforeTimestamp)).array;
  }
}
