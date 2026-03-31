module domain.ports.metric_repository;

import domain.entities.metric;
import domain.types;

/// Port: outgoing - metric data point persistence.
interface MetricRepository
{
    Metric findById(MetricId id);
    Metric[] findByResource(TenantId tenantId, MonitoredResourceId resourceId);
    Metric[] findByName(TenantId tenantId, string metricName);
    Metric[] findByResourceAndName(TenantId tenantId, MonitoredResourceId resourceId, string metricName);
    Metric[] findInTimeRange(TenantId tenantId, MonitoredResourceId resourceId, string metricName, long startTime, long endTime);
    void save(Metric m);
    void saveAll(Metric[] metrics);
    void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}
