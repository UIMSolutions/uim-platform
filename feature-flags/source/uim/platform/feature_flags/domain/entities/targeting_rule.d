/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.domain.entities.targeting_rule;

import uim.platform.feature_flags;

mixin(ShowModule!());

@safe:

/// A rule that targets a specific variant at evaluation time.
/// Rules are evaluated in ascending `priority` order (lower = higher priority).
struct TargetingRule {
    RuleId   id;
    RuleType type_;

    /// Human-readable label
    string   name;
    string   description;

    /// The variant key to serve when this rule matches
    string   variantKey;

    /// Evaluation priority (ascending; 0 = highest priority)
    uint     priority;

    /// USER_MATCH / TENANT_MATCH: list of allowed IDs
    string[] targetIds;

    /// PERCENTAGE_ROLLOUT: 0-100 (integer percent)
    uint     rolloutPercentage;

    /// ATTRIBUTE_MATCH: key/value pairs that must all appear in the evaluation context
    string[string] attributeConstraints;

    bool isNull() const { return id.isNull; }
}
