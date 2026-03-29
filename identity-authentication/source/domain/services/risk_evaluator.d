module uim.platform.identity_authentication.domain.services.risk_evaluator;

import uim.platform.identity_authentication.domain.entities.risk_rule;
import uim.platform.identity_authentication.domain.entities.user;
import uim.platform.identity_authentication.domain.types;

/// Domain service: evaluates risk level for an authentication attempt.
struct RiskEvaluationContext
{
    string ipAddress;
    string userAgent;
    AuthMethod authMethod;
    string[] userGroupIds;
    string userType;
}

/// Pure domain logic for risk evaluation.
RiskLevel evaluateRisk(RiskRule[] rules, User user, RiskEvaluationContext ctx)
{
    RiskLevel highest = RiskLevel.low;

    foreach (rule; rules)
    {
        if (!rule.active)
            continue;

        if (matchesAllConditions(rule.conditions, user, ctx))
        {
            if (rule.resultLevel > highest)
                highest = rule.resultLevel;
        }
    }

    return highest;
}

/// Check which MFA is required given the evaluated risk.
MfaType requiredMfaForRisk(RiskRule[] rules, User user, RiskEvaluationContext ctx)
{
    MfaType required = MfaType.none;

    foreach (rule; rules)
    {
        if (!rule.active)
            continue;

        if (matchesAllConditions(rule.conditions, user, ctx))
        {
            if (rule.requiredMfa != MfaType.none)
                required = rule.requiredMfa;
        }
    }

    return required;
}

private bool matchesAllConditions(RiskCondition[] conditions, User user, RiskEvaluationContext ctx)
{
    import std.algorithm : canFind;

    foreach (cond; conditions)
    {
        if (!matchesCondition(cond, user, ctx))
            return false;
    }
    return true;
}

private bool matchesCondition(RiskCondition cond, User user, RiskEvaluationContext ctx)
{
    import std.conv : to;
    import std.algorithm : canFind;

    switch (cond.conditionType)
    {
    case "ip_range":
        return cond.operator_ == "eq" ? ctx.ipAddress == cond.value : ctx.ipAddress != cond.value;
    case "group":
        bool inGroup = ctx.userGroupIds.canFind(cond.value);
        return cond.operator_ == "in" ? inGroup : !inGroup;
    case "auth_method":
        return ctx.authMethod.to!string == cond.value;
    default:
        return false;
    }
}
