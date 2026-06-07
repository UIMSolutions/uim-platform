/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.domain.entities.flex_change;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

/// A single UI adaptation change created by a key user.
/// Corresponds to a SAPUI5 flexibility change descriptor (change.json).
struct FlexChange {
  mixin TenantEntity!(FlexChangeId);

  string appId_;            // Target application ID (e.g. "my.namespace.AppName")
  string namespace_;        // SAPUI5 namespace (e.g. "apps/my.namespace.AppName/changes/")
  ChangeLayer layer_;       // vendor, customer, user
  ChangeType changeType_;   // move, rename, addField, etc.
  string selector_;         // JSON string: control selector (id/type/viewName)
  string content_;          // JSON string: change-specific content payload
  string reference_;        // File reference (for layered repo transport)
  string support_;          // JSON string: creation/modification metadata
  string dependentSelector_; // JSON string: selectors this change depends on
  string createdBy_;
  string updatedBy_;
  long createdAtTicks_;
  long updatedAtTicks_;
  bool isActive_;           // False if superseded by newer version

  Json toJson() const @trusted {
    auto j = entityToJson(this);
    j["appId"] = Json(appId_);
    j["namespace"] = Json(namespace_);
    j["layer"] = Json(layer_.to!string);
    j["changeType"] = Json(changeType_.to!string);
    j["selector"] = Json(selector_);
    j["content"] = Json(content_);
    j["reference"] = Json(reference_);
    j["support"] = Json(support_);
    j["dependentSelector"] = Json(dependentSelector_);
    j["createdBy"] = Json(createdBy_);
    j["updatedBy"] = Json(updatedBy_);
    j["createdAtTicks"] = Json(createdAtTicks_);
    j["updatedAtTicks"] = Json(updatedAtTicks_);
    j["isActive"] = Json(isActive_);
    return j;
  }
}
