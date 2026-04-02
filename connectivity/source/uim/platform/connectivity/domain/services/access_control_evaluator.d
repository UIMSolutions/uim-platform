module uim.platform.connectivity.domain.services.access_control_evaluator;

import uim.platform.connectivity.domain.entities.access_rule;
import uim.platform.connectivity.domain.types;

/// Result of evaluating access control rules.
struct AccessEvaluation
{
    bool allowed;
    string matchedRuleId;   // empty if no rule matched
    string reason;
}

/// Domain service: evaluates access control rules for on-premise backend requests.
struct AccessControlEvaluator
{
    /// Evaluate whether a request to a virtual host/path is allowed.
    static AccessEvaluation evaluate(
        AccessRule[] rules,
        string virtualHost,
        ushort virtualPort,
        string urlPath,
    )
    {
        // Find the most specific matching rule (longest urlPathPrefix match).
        AccessRule* bestMatch = null;
        size_t bestLen = 0;

        foreach (ref rule; rules)
        {
            if (rule.virtualHost != virtualHost)
                continue;
            if (rule.virtualPort != virtualPort)
                continue;
            if (!pathStartsWith(urlPath, rule.urlPathPrefix))
                continue;

            if (rule.urlPathPrefix.length >= bestLen)
            {
                bestLen = rule.urlPathPrefix.length;
                bestMatch = &rule;
            }
        }

        if (bestMatch is null)
            return AccessEvaluation(false, "", "No matching access rule found");

        if (bestMatch.policy == AccessPolicy.allow)
            return AccessEvaluation(true, bestMatch.id, "Allowed by rule: " ~ bestMatch.description);

        return AccessEvaluation(false, bestMatch.id, "Denied by rule: " ~ bestMatch.description);
    }

    /// Check if a path starts with the given prefix.
    private static bool pathStartsWith(string path, string prefix)
    {
        if (prefix.length == 0)
            return true;
        if (path.length < prefix.length)
            return false;
        return path[0 .. prefix.length] == prefix;
    }
}
