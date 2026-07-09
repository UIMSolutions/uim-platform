/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.domain.enumerations;

import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:
// ─── Storage backend selection ────────────────────────────────────────────────

enum StorageBackend {
  memory_,
  files_,
  mongodb_
}

StorageBackend toStorageBackend(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
    case "memory": return StorageBackend.memory_;
    case "files": return StorageBackend.files_;
    case "mongodb": return StorageBackend.mongodb_;
    default: return StorageBackend.memory_; // default
  }
}

// ─── Change / adaptation layer ───────────────────────────────────────────────

/// SAPUI5 Livechange flexibility layer (who created the change)
enum ChangeLayer {
  vendor_,    // Delivered by SAP or application developer
  customer_,  // Created by key user (tenant-level)
  user_       // Created by end user (personal)
}
ChangeLayer toChangeLayer(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
    case "vendor": return ChangeLayer.vendor_;
    case "customer": return ChangeLayer.customer_;
    case "user": return ChangeLayer.user_;
    default: return ChangeLayer.customer_; // default
  }
}

/// Types of UI changes that key users can apply
enum ChangeType {
  customAdd_,       // Custom add operation
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
  customHide_       // Custom hide operation
}
ChangeType toChangeType(string s) {
  switch (s) {
    case "move":             return ChangeType.move_;
    case "rename":           return ChangeType.rename_;
    case "addField":         return ChangeType.addField_;
    case "hideControl":      return ChangeType.hideControl_;
    case "unhideControl":    return ChangeType.unhideControl_;
    case "addXML":           return ChangeType.addXML_;
    case "setTitle":         return ChangeType.setTitle_;
    case "stashControl":     return ChangeType.stashControl_;
    case "unstashControl":   return ChangeType.unstashControl_;
    case "bindProperty":     return ChangeType.bindProperty_;
    case "unbindProperty":   return ChangeType.unbindProperty_;
    default:                 return ChangeType.customAdd_;
  }
}

/// Type of variant/view
enum VariantType {
  filterBar_,  // Filter bar view variant
  table_,      // Table view variant
  chart_,      // Chart variant
  dialog_,     // Dialog variant
  page_        // Page layout variant
}
VatiantType toVariantType(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
    case "filterbar": return VariantType.filterBar_;
    case "table": return VariantType.table_;
    case "chart": return VariantType.chart_;
    case "dialog": return VariantType.dialog_;
    case "page": return VariantType.page_;
    default: return VariantType.filterBar_; // default
  }
}

/// Version status
enum VersionStatus {
  draft_,      // Not yet activated
  active_,     // Currently active version
  archived_    // Superseded by newer version
}
VersionStatus toVersionStatus(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
    case "draft": return VersionStatus.draft_;
    case "active": return VersionStatus.active_;
    case "archived": return VersionStatus.archived_;
    default: return VersionStatus.draft_; // default
  }
}
/// Personalization scope
enum PersonalizationScope {
  control_,    // Per-control personalization
  page_,       // Full page personalization
  app_         // Application-level personalization
}
PersonalizationScope toPersonalizationScope(string value, bool ignoreCase = true) {
  switch (ignoreCase ? value.toLower() : value) {
    case "control": return PersonalizationScope.control_;
    case "page": return PersonalizationScope.page_;
    case "app": return PersonalizationScope.app_;
    default: return PersonalizationScope.page_; // default
  }
}