module uim.platform.xyz.domain.entities.retention_rule;

import domain.types;

/// Defines how long personal data may be retained for a given purpose.
struct RetentionRule
{
    RetentionRuleId id;
    TenantId tenantId;
    string name;
    string description;
    ProcessingPurpose purpose;
    PersonalDataCategory[] categories;
    int retentionDays;              // maximum retention period
    string legalReference;          // e.g. "HGB §257 (10 years)"
    RetentionRuleStatus status = RetentionRuleStatus.active;
    bool isDefault;
    long createdAt;
    long updatedAt;
}
