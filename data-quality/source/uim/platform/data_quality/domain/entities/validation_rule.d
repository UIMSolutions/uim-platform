module uim.platform.xyz.domain.entities.validation_rule;

import uim.platform.xyz.domain.types;

/// A configurable data quality validation rule.
struct ValidationRule
{
    RuleId id;
    TenantId tenantId;
    string name;
    string description;
    string datasetPattern;      // target dataset / object type
    string fieldName;           // target field
    RuleType ruleType;
    RuleSeverity severity = RuleSeverity.error;
    RuleStatus status = RuleStatus.draft;

    // Rule parameters
    string pattern;             // regex for format_ rules
    string minValue;            // range / length min
    string maxValue;            // range / length max
    string[] allowedValues;     // enumeration set
    string expression;          // custom rule expression
    string referenceDataset;    // reference data lookup target
    string crossFieldName;      // for cross-field rules

    string category;            // grouping label (e.g. "address", "contact")
    int priority;               // execution order (lower = first)
    long createdAt;
    long updatedAt;
}
