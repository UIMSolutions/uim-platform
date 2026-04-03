/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.ports.metric_repository;

import uim.platform.monitoring.domain.entities.metric;
import uim.platform.monitoring.domain.types;

/// Port: outgoing - metric data point persistence.
interface MetricRepository
{
  Metric findById(MetricId id);
  Metric[] findByResource(TenantId tenantId, MonitoredResourceId resourceId);
  Metric[] findByName(TenantId tenantId, string metricName);
  Metric[] findByResourceAndName(TenantId tenantId, MonitoredResourceId resourceId,
      string metricName);
  Metric[] findInTimeRange(TenantId tenantId, MonitoredResourceId resourceId,
      string metricName, long startTime, long endTime);
  void save(Metric m);
  void saveAll(Metric[] metrics);
  void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}
