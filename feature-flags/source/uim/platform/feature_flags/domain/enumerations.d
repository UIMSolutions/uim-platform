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
FlagType toFlagType(string value) {
    mixin(EnumSwitch("FlagType", "FlagType.boolean_"));
}
FlagType[] toFlagType(string[] values) {
    return values.map!(v => v.toFlagType).array;
}
string toString(FlagType value) {
    return value.to!string();
}
string[] toString(FlagType[] values) {
    return values.map!(v => v.toString).array;
}
/// 
unittest {
    mixin(ShowTest!("FlagType"));

    assert("BOOLEAN".toFlagType == FlagType.boolean_);
    assert("STRING".toFlagType == FlagType.string_);
    assert("JSON".toFlagType == FlagType.json_);
    assert("NUMBER".toFlagType == FlagType.number_);

    assert(FlagType.boolean_.toString == "BOOLEAN");
    assert(FlagType.string_.toString == "STRING");
    assert(FlagType.json_.toString == "JSON");
    assert(FlagType.number_.toString == "NUMBER");

    assert(["BOOLEAN", "STRING"].toFlagType == [FlagType.boolean_, FlagType.string_]);
    assert([FlagType.boolean_, FlagType.string_].toString == ["BOOLEAN", "STRING"]);
}

/// Lifecycle state of a feature flag
enum FlagState : string {
    enabled_   = "ENABLED",   /// Flag is active and will be evaluated
    disabled_  = "DISABLED",  /// Flag is inactive, returns default variant
    archived_  = "ARCHIVED"   /// Flag is retired, read-only
}
FlagState toFlagState(string value) {
    mixin(EnumSwitch("FlagState", "FlagState.enabled_"));
}
FlagState[] toFlagState(string[] values) {
    return values.map!(v => v.toFlagState).array;
}
string toString(FlagState value) {
    return value.to!string();
}
string[] toString(FlagState[] values) {
    return values.map!(v => v.toString()).array;
}
/// 
unittest {
    mixin(ShowTest!("FlagState"));

    assert("ENABLED".toFlagState == FlagState.enabled_);
    assert("DISABLED".toFlagState == FlagState.disabled_);
    assert("ARCHIVED".toFlagState == FlagState.archived_);
    assert("unknown".toFlagState == FlagState.enabled_);

    assert(FlagState.enabled_.toString == "ENABLED");
    assert(FlagState.disabled_.toString == "DISABLED");
    assert(FlagState.archived_.toString == "ARCHIVED");

    assert(["ENABLED", "DISABLED"].toFlagState == [FlagState.enabled_, FlagState.disabled_]);
    assert([FlagState.enabled_, FlagState.disabled_].toString == ["ENABLED", "DISABLED"]);
}

/// Type of targeting rule
enum RuleType : string {
    userMatch        = "USER_MATCH",         /// Match specific user IDs
    tenantMatch      = "TENANT_MATCH",       /// Match specific tenant IDs
    percentageRollout = "PERCENTAGE_ROLLOUT", /// Gradual rollout by percentage
    attributeMatch   = "ATTRIBUTE_MATCH"     /// Match on custom context attributes
}
RuleType toRuleType(string value) {
    mixin(EnumSwitch("RuleType", "RuleType.userMatch"));
}
RuleType[] toRuleType(string[] values) {
    return values.map!(v => v.toRuleType).array;
}
string toString(RuleType value) {
    return value.to!string();
}
string[] toString(RuleType[] values) {
    return values.map!(v => v.toString()).array;
}
/// 
unittest {
    mixin(ShowTest!("RuleType"));

    assert("USER_MATCH".toRuleType == RuleType.userMatch);
    assert("TENANT_MATCH".toRuleType == RuleType.tenantMatch);
    assert("PERCENTAGE_ROLLOUT".toRuleType == RuleType.percentageRollout);
    assert("ATTRIBUTE_MATCH".toRuleType == RuleType.attributeMatch);
    assert("unknown".toRuleType == RuleType.userMatch);

    assert(RuleType.userMatch.toString == "USER_MATCH");
    assert(RuleType.tenantMatch.toString == "TENANT_MATCH");
    assert(RuleType.percentageRollout.toString == "PERCENTAGE_ROLLOUT");
    assert(RuleType.attributeMatch.toString == "ATTRIBUTE_MATCH");

    assert(["USER_MATCH", "TENANT_MATCH", "PERCENTAGE_ROLLOUT", "ATTRIBUTE_MATCH"].toRuleType == [RuleType.userMatch, RuleType.tenantMatch, RuleType.percentageRollout, RuleType.attributeMatch]);
    assert([RuleType.userMatch, RuleType.tenantMatch, RuleType.percentageRollout, RuleType.attributeMatch].toString == ["USER_MATCH", "TENANT_MATCH", "PERCENTAGE_ROLLOUT", "ATTRIBUTE_MATCH"]);
}

/// Evaluation context hint for SDK clients
enum EvaluationKind : string {
    boolean_ = "BOOLEAN",
    string_  = "STRING",
    json_    = "JSON",
    number_  = "NUMBER"
}
EvaluationKind toEvaluationKind(string value) {
    mixin(EnumSwitch("EvaluationKind", "EvaluationKind.boolean_"));
}
EvaluationKind[] toEvaluationKind(string[] values) {
    return values.map!(v => v.toEvaluationKind).array;
}
string toString(EvaluationKind value) {
    return value.to!string();
}
string[] toString(EvaluationKind[] values) {
    return values.map!(v => v.toString()).array;
}
///
unittest {
    mixin(ShowTest!("EvaluationKind")); 

    assert("BOOLEAN".toEvaluationKind == EvaluationKind.boolean_);
    assert("STRING".toEvaluationKind == EvaluationKind.string_);
    assert("JSON".toEvaluationKind == EvaluationKind.json_);
    assert("NUMBER".toEvaluationKind == EvaluationKind.number_);
    assert("unknown".toEvaluationKind == EvaluationKind.boolean_);

    assert(EvaluationKind.boolean_.toString == "BOOLEAN");
    assert(EvaluationKind.string_.toString == "STRING");
    assert(EvaluationKind.json_.toString == "JSON");
    assert(EvaluationKind.number_.toString == "NUMBER");    

    assert(["BOOLEAN", "STRING"].toEvaluationKind == [EvaluationKind.boolean_, EvaluationKind.string_]);
    assert([EvaluationKind.boolean_, EvaluationKind.string_].toString == ["BOOLEAN", "STRING"]);
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
AuditAction toAuditAction(string value) {
    mixin(EnumSwitch("AuditAction", "AuditAction.created_"));
}
AuditAction[] toAuditAction(string[] values) {
    return values.map!(v => v.toAuditAction).array;
}
string toString(AuditAction value) {
    return value.to!string();
}
string[] toString(AuditAction[] values) {
    return values.map!(v => v.toString()).array;
}   
///
unittest {
    mixin(ShowTest!("AuditAction"));

    assert("CREATED".toAuditAction == AuditAction.created_);
    assert("UPDATED".toAuditAction == AuditAction.updated_);
    assert("DELETED".toAuditAction == AuditAction.deleted_);
    assert("ENABLED".toAuditAction == AuditAction.enabled_);
    assert("DISABLED".toAuditAction == AuditAction.disabled_);
    assert("ARCHIVED".toAuditAction == AuditAction.archived_);
    assert("unknown".toAuditAction == AuditAction.created_);

    assert(AuditAction.created_.toString == "CREATED");
    assert(AuditAction.updated_.toString == "UPDATED");
    assert(AuditAction.deleted_.toString == "DELETED");
    assert(AuditAction.enabled_.toString == "ENABLED");
    assert(AuditAction.disabled_.toString == "DISABLED");
    assert(AuditAction.archived_.toString == "ARCHIVED");

    assert(["CREATED", "UPDATED", "DELETED", "ENABLED", "DISABLED", "ARCHIVED"].toAuditAction == [AuditAction.created_, AuditAction.updated_, AuditAction.deleted_, AuditAction.enabled_, AuditAction.disabled_, AuditAction.archived_]);
    assert([AuditAction.created_, AuditAction.updated_, AuditAction.deleted_, AuditAction.enabled_, AuditAction.disabled_, AuditAction.archived_].toString == ["CREATED", "UPDATED", "DELETED", "ENABLED", "DISABLED", "ARCHIVED"]);
}

/// Storage backend selector (for infrastructure routing)
enum StorageBackend : string {
    memory_  = "MEMORY",
    file_    = "FILE",
    mongodb_ = "MONGODB"
}
StorageBackend toStorageBackend(string value) {
    mixin(EnumSwitch("StorageBackend", "StorageBackend.memory_"));
}
StorageBackend[] toStorageBackend(string[] values) {
    return values.map!(v => v.toStorageBackend).array;
}
string toString(StorageBackend value) {
    return value.to!string();
}
string[] toString(StorageBackend[] values) {
    return values.map!(v => v.toString()).array;
}
///
unittest {
    mixin(ShowTest!("StorageBackend"));

    assert("MEMORY".toStorageBackend == StorageBackend.memory_);
    assert("FILE".toStorageBackend == StorageBackend.file_);
    assert("MONGODB".toStorageBackend == StorageBackend.mongodb_);
    assert("unknown".toStorageBackend == StorageBackend.memory_);  

    assert(StorageBackend.memory_.toString == "MEMORY");
    assert(StorageBackend.file_.toString == "FILE");
    assert(StorageBackend.mongodb_.toString == "MONGODB");

    assert(["MEMORY", "FILE"].toStorageBackend == [StorageBackend.memory_, StorageBackend.file_]);
    assert([StorageBackend.memory_, StorageBackend.file_].toString == ["MEMORY", "FILE"]);
}
