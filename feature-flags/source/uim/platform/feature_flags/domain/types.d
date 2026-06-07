/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.domain.types;

import uim.platform.feature_flags;

// mixin(ShowModule!());

@safe:

/// Strongly-typed identifier for a FeatureFlag
struct FlagId {
    string value;
    alias value this;

    bool isNull() const { return value.length == 0; }
    static FlagId init_() { return FlagId(""); }
}

/// Strongly-typed identifier for a FlagVariant
struct VariantId {
    string value;
    alias value this;

    bool isNull() const { return value.length == 0; }
}

/// Strongly-typed identifier for a TargetingRule
struct RuleId {
    string value;
    alias value this;

    bool isNull() const { return value.length == 0; }
}

/// Strongly-typed identifier for a ServiceInstance
struct ServiceInstanceId {
    string value;
    alias value this;

    bool isNull() const { return value.length == 0; }
}

/// Strongly-typed identifier for an AuditEntry
struct AuditEntryId {
    string value;
    alias value this;

    bool isNull() const { return value.length == 0; }
}

/// Tenant scoping identifier
alias TenantId = string;

/// User context identifier used for evaluation
alias UserId = string;

/// Generic service result for command operations
struct FlagResult {
    bool   success;
    string id;
    string message;

    bool hasError() const { return !success; }
}
