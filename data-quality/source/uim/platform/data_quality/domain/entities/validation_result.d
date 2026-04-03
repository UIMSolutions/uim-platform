module uim.platform.xyz.domain.entities.validation_result;

import domain.types;

/// Result of running validation rules against a single record.
struct ValidationResult
{
    RecordId recordId;
    TenantId tenantId;
    DatasetId datasetId;
    RuleViolation[] violations;
    int totalRulesChecked;
    int passedRules;
    int failedRules;
    double qualityScore;        // 0.0 - 100.0
    long validatedAt;
}

/// A single rule violation found during validation.
struct RuleViolation
{
    RuleId ruleId;
    string ruleName;
    string fieldName;
    string fieldValue;
    RuleSeverity severity;
    string message;
    string suggestedValue;      // auto-correction hint
}
