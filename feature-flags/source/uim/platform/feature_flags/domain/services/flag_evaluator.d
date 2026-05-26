/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.domain.services.flag_evaluator;

import uim.platform.feature_flags;
import std.algorithm : sort;
import std.array     : array;
import std.conv      : to;
import std.digest    : hexDigest;
import std.digest.crc : CRC32;

mixin(ShowModule!());

@safe:

/// Evaluation context supplied by the SDK caller.
struct EvaluationContext {
    TenantId      tenantId;
    UserId        userId;
    string[string] attributes;
}

/// Result of evaluating a feature flag.
struct EvaluationResult {
    string  flagName;
    string  variantKey;
    string  variantValue;
    FlagType  type_;
    bool    enabled;
    string  reason;   /// "DEFAULT" | "RULE_MATCH" | "DISABLED" | "UNKNOWN_FLAG"
}

/// Pure domain service — no I/O, evaluates a flag for a given context.
class FlagEvaluator {
    @safe:

    EvaluationResult evaluate(FeatureFlag flag_, EvaluationContext ctx) const {
        if (flag_.isNull)
            return EvaluationResult(flag_.name, "", "", FlagType.boolean_, false, "UNKNOWN_FLAG");

        if (flag_.state_ == FlagState.disabled_)
            return buildResult(flag_, flag_.defaultVariant, "DISABLED");

        if (flag_.state_ == FlagState.archived_)
            return buildResult(flag_, flag_.defaultVariant, "ARCHIVED");

        // Evaluate rules in ascending priority order
        auto sortedRules = flag_.rules.dup;
        sortedRules.sort!((a, b) => a.priority < b.priority);

        foreach (rule; sortedRules) {
            if (matchesRule(rule, ctx)) {
                return buildResult(flag_, rule.variantKey, "RULE_MATCH");
            }
        }

        return buildResult(flag_, flag_.defaultVariant, "DEFAULT");
    }

    private:

    bool matchesRule(TargetingRule rule, EvaluationContext ctx) const {
        final switch (rule.type_) {
            case RuleType.userMatch:
                import std.algorithm : canFind;
                return rule.targetIds.canFind(ctx.userId);

            case RuleType.tenantMatch:
                import std.algorithm : canFind;
                return rule.targetIds.canFind(ctx.tenantId);

            case RuleType.percentageRollout:
                return stableHashPercent(ctx.userId) < rule.rolloutPercentage;

            case RuleType.attributeMatch:
                foreach (k, v; rule.attributeConstraints) {
                    auto ptr = k in ctx.attributes;
                    if (ptr is null || *ptr != v) return false;
                }
                return true;
        }
    }

    uint stableHashPercent(string id) const {
        import std.digest.crc : crc32Of;
        auto bytes = cast(ubyte[]) id;
        auto h = crc32Of(bytes);
        uint val = (cast(uint) h[0]) | ((cast(uint) h[1]) << 8)
                 | ((cast(uint) h[2]) << 16) | ((cast(uint) h[3]) << 24);
        return val % 100;
    }

    EvaluationResult buildResult(FeatureFlag flag_, string variantKey, string reason) const {
        auto variant = flag_.findVariant(variantKey);
        return EvaluationResult(
            flag_.name,
            variantKey,
            variant.value,
            flag_.type_,
            flag_.state_ == FlagState.enabled_,
            reason
        );
    }
}
