module domain.entities.retention_policy;

import domain.types;

/// Retention policy — how long audit data is kept.
struct RetentionPolicy
{
    RetentionPolicyId id;
    TenantId tenantId;
    string name;
    string description;
    int retentionDays = 90;     // SAP default is 90 days
    AuditCategory[] categories; // which categories this policy covers
    RetentionStatus status = RetentionStatus.active;
    bool isDefault;
    long createdAt;
    long updatedAt;
}
