/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.domain.entities.flex_application;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

/// A SAPUI5 application registered with the UI Flexibility Service.
/// Applications must be registered before key users can create adaptations.
struct FlexApplication {
  mixin TenantEntity!(FlexApplicationId);

  string namespace_;   // SAPUI5 component namespace (e.g. "my.company.MyApp")
  string appId_;       // Unique application identifier within namespace
  string description_; // Human-readable description
  bool isActive_;      // Whether key user adaptations are enabled
  string validFrom_;   // ISO date when adaptations become effective
  string validTo_;     // ISO date when adaptations expire (empty = unlimited)
  string owner_;       // User/team responsible for this application
  string version_;     // Application version string

  Json toJson() const @trusted {
    auto j = entityToJson(this);
    j["namespace"] = Json(namespace_);
    j["appId"] = Json(appId_);
    j["description"] = Json(description_);
    j["isActive"] = Json(isActive_);
    j["validFrom"] = Json(validFrom_);
    j["validTo"] = Json(validTo_);
    j["owner"] = Json(owner_);
    j["version"] = Json(version_);
    return j;
  }
}
