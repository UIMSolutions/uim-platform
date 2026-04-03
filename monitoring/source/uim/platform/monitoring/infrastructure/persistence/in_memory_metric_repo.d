module uim.platform.xyz.infrastructure.persistence.memory.metric_repo;

import domain.types;
import domain.entities.metric;
import domain.ports.metric_repository;

import std.algorithm : filter;
import std.array : array;

class MemoryMetricRepository : MetricRepository
{
    private Metric[] store;

    Metric findById(MetricId id)
    {
        foreach (ref m; store)
            if (m.id == id)
                return m;
        return Metric.init;
    }

    Metric[] findByResource(TenantId tenantId, MonitoredResourceId resourceId)
    {
        return store.filter!(m => m.tenantId == tenantId && m.resourceId == resourceId).array;
    }

    Metric[] findByName(TenantId tenantId, string metricName)
    {
        return store.filter!(m => m.tenantId == tenantId && m.name == metricName).array;
    }

    Metric[] findByResourceAndName(TenantId tenantId, MonitoredResourceId resourceId, string metricName)
    {
        return store.filter!(m =>
            m.tenantId == tenantId && m.resourceId == resourceId && m.name == metricName
        ).array;
    }

    Metric[] findInTimeRange(TenantId tenantId, MonitoredResourceId resourceId,
        string metricName, long startTime, long endTime)
    {
        return store.filter!(m =>
            m.tenantId == tenantId &&
            m.resourceId == resourceId &&
            m.name == metricName &&
            m.timestamp >= startTime &&
            m.timestamp <= endTime
        ).array;
    }

    void save(Metric m) { store ~= m; }

    void saveAll(Metric[] metrics)
    {
        foreach (ref m; metrics)
            store ~= m;
    }

    void removeOlderThan(TenantId tenantId, long beforeTimestamp)
    {
        store = store.filter!(m =>
            !(m.tenantId == tenantId && m.timestamp < beforeTimestamp)
        ).array;
    }
}
