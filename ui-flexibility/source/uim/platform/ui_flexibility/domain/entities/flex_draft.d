/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.domain.entities.flex_draft;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

/// Work-in-progress UI changes that are not yet activated/published to end users.
/// Each application has at most one active draft per tenant.
struct FlexDraft {
  mixin TenantEntity!(FlexDraftId);

  string appId_;       // Target application
  string[] changeIds_; // Pending FlexChange IDs in this draft
  long updatedAt_;   // ISO timestamp of last modification
  string updatedBy_;   // User who last modified the draft
  string baseVersionId_; // Version this draft is based on (empty = from scratch)
  long changeCount_;   // Cached count of pending changes

  Json toJson() const @trusted {
    auto j = entityToJson(this);
    j["appId"] = Json(appId_);
    auto ids = Json.emptyArray;
    foreach (cid; changeIds_) ids ~= Json(cid);
    j["changeIds"] = ids;
    j["updatedAt"] = Json(updatedAt_);
    j["updatedBy"] = Json(updatedBy_);
    j["baseVersionId"] = Json(baseVersionId_);
    j["changeCount"] = Json(changeCount_);
    return j;
  }
}
