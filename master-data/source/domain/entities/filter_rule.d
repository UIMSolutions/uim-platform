module domain.entities.filter_rule;

import domain.types;

/// A filter rule for selective master data distribution.
struct FilterRule
{
    FilterRuleId id;
    TenantId tenantId;
    string name;
    string description;

    // Target scope
    MasterDataCategory category = MasterDataCategory.businessPartner;
    DataModelId dataModelId;
    string objectType;

    // Conditions
    FilterCondition[] conditions;
    string logicOperator;           // "AND" or "OR"

    bool isActive;
    string createdBy;
    long createdAt;
    long modifiedAt;
}

/// A single filter condition.
struct FilterCondition
{
    string fieldName;
    FilterOperator operator = FilterOperator.equals;
    string value;
    string[] valueList;             // For inList / notInList operators
    string lowerBound;              // For between operator
    string upperBound;              // For between operator
}
