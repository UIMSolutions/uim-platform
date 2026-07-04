/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.domain.entities.flex_version;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

/// An activated snapshot of UI adaptations. Key users can reactivate previous versions.
struct FlexVersion {
  mixin TenantEntity!(FlexVersionId);

  string appId_;
  long versionNumber_;     // Monotonically increasing version number
  string displayName_;     // Human-readable label
  string description_;     // What changed in this version
  VersionStatus status_;   // draft, active, archived
  string activatedAt_;     // ISO timestamp of activation
  string activatedBy_;     // User ID who activated
  long changeCount_;       // Number of changes in this version
  string[] changeIds_;     // References to the FlexChange IDs included

  Json toJson() const @trusted {
    auto j = entityToJson(this);
    j["appId"] = Json(appId_);
    j["versionNumber"] = Json(versionNumber_);
    j["displayName"] = Json(displayName_);
    j["description"] = Json(description_);
    j["status"] = Json(status_.to!string);
    j["activatedAt"] = Json(activatedAt_);
    j["activatedBy"] = Json(activatedBy_);
    j["changeCount"] = Json(changeCount_);
    auto ids = Json.emptyArray;
    foreach (cid; changeIds_) ids ~= Json(cid);
    j["changeIds"] = ids;
    return j;
  }
}
