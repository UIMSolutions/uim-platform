/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.application.dto;

import uim.platform.feature_flags;

// mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// Variant DTOs
// ---------------------------------------------------------------------------

struct VariantDTO {
    string key;
    string name;
    string description;
    string value;
    uint   weight;
}

// ---------------------------------------------------------------------------
// Targeting Rule DTOs
// ---------------------------------------------------------------------------

struct TargetingRuleDTO {
    string   name;
    string   description;
    string   type_;           /// RuleType string
    string   variantKey;
    uint     priority;
    string[] targetIds;
    uint     rolloutPercentage;
    string[string] attributeConstraints;
}

// ---------------------------------------------------------------------------
// Feature Flag DTOs
// ---------------------------------------------------------------------------

struct CreateFeatureFlagRequest {
    string   name;
    string   description;
    string   type_;           /// FlagType string
    string   instanceId;
    string   defaultVariant;
    VariantDTO[]       variants;
    TargetingRuleDTO[] rules;
    string[string]     labels;
    string   createdBy;
}

struct UpdateFeatureFlagRequest {
    string   description;
    string   defaultVariant;
    VariantDTO[]       variants;
    TargetingRuleDTO[] rules;
    string[string]     labels;
    string   updatedBy;
}

struct PatchFeatureFlagRequest {
    string   state_;     /// FlagState string: "ENABLED" | "DISABLED" | "ARCHIVED"
    string   updatedBy;
}

// ---------------------------------------------------------------------------
// Service Instance DTOs
// ---------------------------------------------------------------------------

struct CreateServiceInstanceRequest {
    TenantId tenantId;
    string name;
    string description;
    string bindingGuid;
    string[string] labels;
    UserId createdBy;
}

struct UpdateServiceInstanceRequest {
    TenantId tenantId;
    string description;
    string[string] labels;
    UserId updatedBy;
}

// ---------------------------------------------------------------------------
// Evaluation DTOs
// ---------------------------------------------------------------------------
// Note: For simplicity, we are using string[string] for attributes, but in a real implementation, you might want a more structured approach.

struct EvaluationRequest {
    TenantId tenantId;
    string   flagName;
    string   instanceId;
    UserId   userId;
    string[string] attributes;
}

struct BulkEvaluationRequest {
    string   instanceId;
    TenantId tenantId;
    UserId   userId;
    string[string] attributes;
}
