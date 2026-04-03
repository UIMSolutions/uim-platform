module uim.platform.xyz.domain.entities.metric;

import domain.types;

/// A single metric data point.
struct Metric
{
    MetricId id;
    TenantId tenantId;
    MonitoredResourceId resourceId;
    MetricDefinitionId definitionId;
    string name;
    double value_;
    MetricUnit unit = MetricUnit.none;
    MetricCategory category = MetricCategory.custom;
    string[string] labels;
    long timestamp;
}

/// Aggregated metric summary over a time window.
struct MetricSummary
{
    string name;
    MonitoredResourceId resourceId;
    double minValue;
    double maxValue;
    double avgValue;
    double sumValue;
    long dataPointCount;
    long windowStartTime;
    long windowEndTime;
}
