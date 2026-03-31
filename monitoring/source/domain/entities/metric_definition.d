module domain.entities.metric_definition;

import domain.types;

/// Definition of a metric that can be collected for monitored resources.
struct MetricDefinition
{
    MetricDefinitionId id;
    TenantId tenantId;
    string name;
    string displayName;
    string description;
    MetricCategory category = MetricCategory.custom;
    MetricUnit unit = MetricUnit.none;
    AggregationMethod aggregation = AggregationMethod.average;
    bool isCustom;
    bool isEnabled = true;
    string createdBy;
    long createdAt;
}
