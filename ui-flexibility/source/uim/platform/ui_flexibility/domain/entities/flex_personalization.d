/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.domain.entities.flex_personalization;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

/// End-user personal UI settings (e.g. column order, saved searches).
/// Scoped to individual user + application + control.
struct FlexPersonalization {
  mixin TenantEntity!(FlexPersonalizationId);

  string appId_;            // Target application
  string userId_;           // End user identifier
  string controlId_;        // SAPUI5 control ID being personalized
  PersonalizationScope scope_;
  ChangeType changeType_;   // What kind of personalization
  string content_;          // JSON string with personalization data
  long updatedAt_;        // ISO timestamp
  bool isSynced_;           // Whether synced to server

  Json toJson() const @trusted {
    auto j = entityToJson(this);
    j["appId"] = Json(appId_);
    j["userId"] = Json(userId_);
    j["controlId"] = Json(controlId_);
    j["scope"] = Json(scope_.to!string);
    j["changeType"] = Json(changeType_.to!string);
    j["content"] = Json(content_);
    j["updatedAt"] = Json(updatedAt_);
    j["isSynced"] = Json(isSynced_);
    return j;
  }
}
