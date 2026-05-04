/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.domain.ports.repositories.metrics;

// import uim.platform.monitoring.domain.entities.metric;
// import uim.platform.monitoring.domain.types;
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
/// Port: outgoing - metric data point persistence.
interface MetricRepository : ITenantRepository!(Metric, MetricId) {

    bool existsByName(TenantId tenantId, string metricName);
    Metric findByName(TenantId tenantId, string metricName);
    void removeByName(TenantId tenantId, string metricName);

    size_t countByResource(TenantId tenantId, MonitoredResourceId resourceId);
    Metric[] findByResource(TenantId tenantId, MonitoredResourceId resourceId);
    void removeByResource(TenantId tenantId, MonitoredResourceId resourceId);

    size_t countByResourceAndName(TenantId tenantId, MonitoredResourceId resourceId, string metricName);
    Metric[] findByResourceAndName(TenantId tenantId, MonitoredResourceId resourceId,
        string metricName);
    void removeByResourceAndName(TenantId tenantId, MonitoredResourceId resourceId,
        string metricName);

    size_t countByResourceAndName(TenantId tenantId, MonitoredResourceId resourceId, string metricName);
    Metric[] findInTimeRange(TenantId tenantId, MonitoredResourceId resourceId,
        string metricName, long startTime, long endTime);
    void removeInTimeRange(TenantId tenantId, MonitoredResourceId resourceId,
        string metricName, long startTime, long endTime);

    void removeOlderThan(TenantId tenantId, long beforeTimestamp);
}
