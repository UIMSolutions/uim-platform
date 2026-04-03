module uim.platform.data.quality.domain.entities.cleansing_rule;

import uim.platform.data.quality.domain.types;

/// A data cleansing / transformation rule.
struct CleansingRule
{
    RuleId id;
    TenantId tenantId;
    string name;
    string description;
    string datasetPattern;
    string fieldName;
    CleansingAction action;
    RuleStatus status = RuleStatus.draft;

    // Action parameters
    string findPattern;         // regex to find
    string replaceWith;         // replacement value
    string defaultValue;        // for defaulted action
    string lookupDataset;       // reference data for enrichment
    string lookupField;         // field to look up
    bool trimWhitespace;
    bool normalizeCase;         // lowercase / uppercase / titlecase
    string caseMode;            // "lower", "upper", "title"
    bool removeDiacritics;

    string category;
    int priority;
    long createdAt;
    long updatedAt;
}
