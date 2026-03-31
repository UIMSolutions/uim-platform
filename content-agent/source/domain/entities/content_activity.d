module domain.entities.content_activity;

import domain.types;

/// Audit record for a content operation.
struct ContentActivity
{
    ContentActivityId id;
    TenantId tenantId;
    ActivityType activityType;
    ActivitySeverity severity = ActivitySeverity.info;
    string entityId;
    string entityName;
    string description;
    string performedBy;
    long timestamp;
    string details;
}
