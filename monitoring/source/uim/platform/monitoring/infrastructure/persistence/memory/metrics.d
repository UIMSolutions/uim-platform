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
class MemoryMetricRepository :TenantRepository!(Metric, MetricId), MetricRepository {
  private Metric[MetricId][TenantId] store;

  bool existsByTenant(string tenantId) {
    return existsByTenant(TenantId(tenantId));
  }

  bool existsByTenant(TenantId tenantId) {
    return (tenantId in store) ? true : false;
  }



  Metric findById(MetricId id) {
    foreach (tenantId, metrics; findAll) {
      if (id in metrics)
        return metrics[id];
    }
    return Metric.init;
  }

  Metric findById(string tenantId, string id) {
    return findById(TenantId(tenantId), MetricId(id));
  }

  Metric findById(TenantId tenantId, MetricId id) {
    return existsById(tenantId, id) ? store[tenantId][id] : Metric.init;
  }

  Metric[] findByTenant(string tenantId) {
    return findByTenant(TenantId(tenantId));
  }

  Metric[] findByTenant(TenantId tenantId) {
    return existsByTenant(tenantId) ? store[tenantId].byValue.array : null;
  }

  Metric[] findByResource(string tenantId, MonitoredResourceId resourceId) {
    return findByResource(TenantId(tenantId), resourceId);
  }

  Metric[] findByResource(TenantId tenantId, MonitoredResourceId resourceId) {
    return findByTenant(tenantId).filter!(m => m.resourceId == resourceId).array;
  }

  Metric[] findByName(string tenantId, string metricName) {
    return findByName(TenantId(tenantId), metricName);
  }

  Metric[] findByName(TenantId tenantId, string metricName) {
    return findByTenant(tenantId).filter!(m => m.name == metricName).array;
  }

  Metric[] findByResourceAndName(string tenantId, string resourceId, string metricName) {
    return findByResourceAndName(TenantId(tenantId), MonitoredResourceId(resourceId), metricName);
  }

  Metric[] findByResourceAndName(TenantId tenantId, MonitoredResourceId resourceId, string metricName) {
    return findByResource(tenantId, resourceId).filter!(m => m.name == metricName).array;
  }

  Metric[] findInTimeRange(TenantId tenantId, MonitoredResourceId resourceId,
      string metricName, long startTime, long endTime) {
    return findByResourceAndName(tenantId, resourceId, metricName).filter!(m => m.timestamp >= startTime && m.timestamp <= endTime).array;
  }

  void save(Metric m) {
    if (!existsByTenant(m.tenantId)) {
      Metric[MetricId] metrics;
      store[m.tenantId] = metrics;
    }
    store[m.tenantId][m.id] = m;
  }

  void saveAll(Metric[] metrics) {
    foreach (m; metrics)
      save(m);
  }

  void removeOlderThan(TenantId tenantId, long beforeTimestamp) {
    if (!existsByTenant(tenantId))
      return;

    auto metrics = store[tenantId];
    foreach (id, metric; metrics) {
      if (metric.timestamp < beforeTimestamp) {
        metrics.remove(id);
      }
    }
    store[tenantId] = metrics;
  }
}
