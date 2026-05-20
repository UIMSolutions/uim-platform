/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.application.dto;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

// ─── Generic command result ───────────────────────────────────────────────────

struct CommandResult {
  bool success;
  string id;
  string errorMessage;
}

// ─── FlexChange DTOs ─────────────────────────────────────────────────────────

struct CreateFlexChangeRequest {
  string tenantId;
  FlexChangeId changeId;
  string appId;
  string namespace_;
  ChangeLayer layer_;
  ChangeType changeType_;
  string selector_;
  string content_;
  string reference_;
  string support_;
  string dependentSelector_;
  string createdBy_;
}

struct UpdateFlexChangeRequest {
  string tenantId;
  FlexChangeId changeId;
  string selector_;
  string content_;
  string reference_;
  string updatedBy_;
  bool isActive_;
}

// ─── FlexVariant DTOs ────────────────────────────────────────────────────────

struct CreateFlexVariantRequest {
  string tenantId;
  FlexVariantId variantId;
  string appId;
  VariantType variantType_;
  string variantName_;
  string content_;
  bool isDefault_;
  bool isPublic_;
  ChangeLayer layer_;
  string author_;
}

struct UpdateFlexVariantRequest {
  string tenantId;
  FlexVariantId variantId;
  string variantName_;
  string content_;
  bool isDefault_;
  bool isPublic_;
}

// ─── FlexVersion DTOs ────────────────────────────────────────────────────────

struct CreateFlexVersionRequest {
  string tenantId;
  FlexVersionId versionId;
  string appId;
  string displayName_;
  string description_;
  string activatedBy_;
  string[] changeIds_;
}

struct UpdateFlexVersionRequest {
  string tenantId;
  FlexVersionId versionId;
  string displayName_;
  string description_;
  VersionStatus status_;
}

/// Activate a specific version (makes it the active version, archives others)
struct ActivateVersionRequest {
  string tenantId;
  FlexVersionId versionId;
  string appId;
  string activatedBy_;
}

// ─── FlexDraft DTOs ──────────────────────────────────────────────────────────

struct CreateFlexDraftRequest {
  string tenantId;
  FlexDraftId draftId;
  string appId;
  string updatedBy_;
  string baseVersionId_;
}

struct UpdateFlexDraftRequest {
  string tenantId;
  FlexDraftId draftId;
  string[] changeIds_;
  string updatedBy_;
}

/// Publish a draft: creates a new activated FlexVersion from draft changes
struct PublishDraftRequest {
  string tenantId;
  FlexDraftId draftId;
  string appId;
  string displayName_;
  string description_;
  string activatedBy_;
}

// ─── FlexPersonalization DTOs ────────────────────────────────────────────────

struct CreateFlexPersonalizationRequest {
  string tenantId;
  FlexPersonalizationId personalizationId;
  string appId;
  string userId_;
  string controlId_;
  PersonalizationScope scope_;
  ChangeType changeType_;
  string content_;
}

struct UpdateFlexPersonalizationRequest {
  string tenantId;
  FlexPersonalizationId personalizationId;
  string content_;
  bool isSynced_;
}

// ─── FlexApplication DTOs ────────────────────────────────────────────────────

struct CreateFlexApplicationRequest {
  string tenantId;
  FlexApplicationId applicationId;
  string namespace_;
  string appId;
  string description_;
  bool isActive_;
  string validFrom_;
  string validTo_;
  string owner_;
  string version_;
}

struct UpdateFlexApplicationRequest {
  string tenantId;
  FlexApplicationId applicationId;
  string description_;
  bool isActive_;
  string validFrom_;
  string validTo_;
  string owner_;
  string version_;
}
