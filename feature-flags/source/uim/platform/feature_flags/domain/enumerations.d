/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.domain.enumerations;

import uim.platform.feature_flags;

// mixin(ShowModule!());

@safe:

/// Type of a feature flag value
enum FlagType : string {
    boolean_   = "BOOLEAN",   /// Simple on/off flag
    string_    = "STRING",    /// String-valued flag with multiple variants
    json_      = "JSON",      /// JSON-valued flag for complex configuration
    number_    = "NUMBER"     /// Numeric flag (integer or float)
}

/// Lifecycle state of a feature flag
enum FlagState : string {
    enabled_   = "ENABLED",   /// Flag is active and will be evaluated
    disabled_  = "DISABLED",  /// Flag is inactive, returns default variant
    archived_  = "ARCHIVED"   /// Flag is retired, read-only
}

/// Type of targeting rule
enum RuleType : string {
    userMatch        = "USER_MATCH",         /// Match specific user IDs
    tenantMatch      = "TENANT_MATCH",       /// Match specific tenant IDs
    percentageRollout = "PERCENTAGE_ROLLOUT", /// Gradual rollout by percentage
    attributeMatch   = "ATTRIBUTE_MATCH"     /// Match on custom context attributes
}

/// Evaluation context hint for SDK clients
enum EvaluationKind : string {
    boolean_ = "BOOLEAN",
    string_  = "STRING",
    json_    = "JSON",
    number_  = "NUMBER"
}

/// Change-type recorded in the audit log
enum AuditAction : string {
    created_  = "CREATED",
    updated_  = "UPDATED",
    deleted_  = "DELETED",
    enabled_  = "ENABLED",
    disabled_ = "DISABLED",
    archived_ = "ARCHIVED"
}

/// Storage backend selector (for infrastructure routing)
enum StorageBackend : string {
    memory_  = "MEMORY",
    file_    = "FILE",
    mongodb_ = "MONGODB"
}
