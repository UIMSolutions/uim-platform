module domain.entities.risk_rule;

import domain.types;

/// Risk-based authentication rule.
struct RiskRule
{
    string id;
    TenantId tenantId;
    string name;
    RiskCondition[] conditions;
    RiskLevel resultLevel;
    MfaType requiredMfa = MfaType.none; // MFA to enforce when rule triggers
    bool active = true;
}

/// Condition that triggers a risk evaluation.
struct RiskCondition
{
    string conditionType; // "ip_range", "group", "user_type", "auth_method", "geo"
    string operator_;     // "eq", "not_eq", "in", "not_in"
    string value;
}
