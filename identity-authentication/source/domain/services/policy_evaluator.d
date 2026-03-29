module domain.services.policy_evaluator;

import domain.entities.policy;
import domain.entities.user;
import domain.types;

/// Domain service: evaluates authorization policies against a user.
struct PolicyEvaluationContext
{
    string ipAddress;
    AuthMethod authMethod;
    string[] userGroupIds;
}

/// Returns true if the user satisfies all rules in the policy.
bool evaluatePolicy(AuthorizationPolicy policy, User user, PolicyEvaluationContext ctx)
{
    if (!policy.active)
        return true; // Inactive policies pass

    foreach (rule; policy.rules)
    {
        if (!evaluateRule(rule, user, ctx))
            return false;
    }
    return true;
}

/// Returns the list of policies that deny access.
AuthorizationPolicy[] findDenyingPolicies(AuthorizationPolicy[] policies, User user, PolicyEvaluationContext ctx)
{
    AuthorizationPolicy[] denying;
    foreach (policy; policies)
    {
        if (!evaluatePolicy(policy, user, ctx))
            denying ~= policy;
    }
    return denying;
}

private bool evaluateRule(PolicyRule rule, User user, PolicyEvaluationContext ctx)
{
    import std.conv : to;
    import std.algorithm : canFind;

    switch (rule.attribute)
    {
    case "group":
        bool inGroup = ctx.userGroupIds.canFind(rule.value);
        return rule.operator_ == "eq" || rule.operator_ == "in" ? inGroup : !inGroup;
    case "ip_range":
        return rule.operator_ == "eq" ? ctx.ipAddress == rule.value : ctx.ipAddress != rule.value;
    case "auth_method":
        return ctx.authMethod.to!string == rule.value;
    default:
        return true;
    }
}
