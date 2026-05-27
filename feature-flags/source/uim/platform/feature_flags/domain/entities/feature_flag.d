/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.domain.entities.feature_flag;

import uim.platform.feature_flags;
import std.json : JSONValue;

mixin(ShowModule!());

@safe:

/// Core domain entity: a named feature flag with type, state, variants and rules.
struct FeatureFlag {
    FlagId    id;
    TenantId  tenantId;

    string    name;           /// Unique name within a service instance (e.g. "dark-mode")
    string    description;
    FlagType  type_;          /// BOOLEAN | STRING | JSON | NUMBER
    FlagState state_;         /// ENABLED | DISABLED | ARCHIVED

    /// Identifier of the service instance this flag belongs to
    ServiceInstanceId instanceId;

    /// The default variant key returned when no targeting rule matches
    string    defaultVariant;

    /// All declared variants for this flag
    FlagVariant[] variants;

    /// Ordered list of targeting rules (evaluated top-down)
    TargetingRule[] rules;

    /// Arbitrary key/value labels for organisational filtering
    string[string] labels;

    /// ISO-8601 creation / update timestamps (strings for portability)
    long createdAt;
    long updatedAt;
    UserId createdBy;
    UserId updatedBy;

    bool isNull() const { return id.isNull; }

    /// Return the variant matching `key`, or a zero-value struct.
    FlagVariant findVariant(string key) const {
        foreach (v; variants)
            if (v.key == key) return v;
        return FlagVariant.init;
    }
}
