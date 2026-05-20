/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.domain.types;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

// ─── Domain ID types ─────────────────────────────────────────────────────────

struct FlexChangeId {
  mixin DomainId;
}

struct FlexVariantId {
  mixin DomainId;
}

struct FlexVersionId {
  mixin DomainId;
}

struct FlexDraftId {
  mixin DomainId;
}

struct FlexPersonalizationId {
  mixin DomainId;
}

struct FlexApplicationId {
  mixin DomainId;
}

// ─── Storage backend selection ────────────────────────────────────────────────

enum StorageBackend {
  memory_,
  files_,
  mongodb_
}

// ─── Change / adaptation layer ───────────────────────────────────────────────

/// SAPUI5 Livechange flexibility layer (who created the change)
enum ChangeLayer {
  vendor_,    // Delivered by SAP or application developer
  customer_,  // Created by key user (tenant-level)
  user_       // Created by end user (personal)
}

/// Types of UI changes that key users can apply
enum ChangeType {
  move_,            // Move UI control to different position
  rename_,          // Rename a label or title
  addField_,        // Add a new field to a form or table
  hideControl_,     // Hide a UI control
  unhideControl_,   // Make a hidden control visible again
  addXML_,          // Insert custom XML fragment
  setTitle_,        // Change title of a section or page
  stashControl_,    // Stash (temporarily remove) a control
  unstashControl_,  // Restore a stashed control
  addDelegateProperty_,   // Add property via delegate
  removeDelegateProperty_,
  bindProperty_,    // Bind property to model path
  unbindProperty_,
  customAdd_,       // Custom add operation
  customHide_       // Custom hide operation
}

/// Type of variant/view
enum VariantType {
  filterBar_,  // Filter bar view variant
  table_,      // Table view variant
  chart_,      // Chart variant
  dialog_,     // Dialog variant
  page_        // Page layout variant
}

/// Version status
enum VersionStatus {
  draft_,      // Not yet activated
  active_,     // Currently active version
  archived_    // Superseded by newer version
}

/// Personalization scope
enum PersonalizationScope {
  control_,    // Per-control personalization
  page_,       // Full page personalization
  app_         // Application-level personalization
}
