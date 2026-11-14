/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.entities.directory;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// A directory is a grouping entity within a global account for
/// organizing subaccounts and managing entitlements/authorizations.
///
/// Children (subdirectories, subaccounts) reference their parent; the
/// hierarchy is always derived from the repositories, never stored twice.
struct AccountDirectory {
  mixin TenantEntity!DirectoryId;

  GlobalAccountId globalAccountId;
  DirectoryId parentDirectoryId; // empty if root-level
  string displayName;
  string description;
  DirectoryStatus status = DirectoryStatus.active;
  DirectoryFeature[] features; // entitlements, authorizations
  bool manageEntitlements;
  bool manageAuthorizations;
  string[string] labels;
  string[string] customProperties;

  bool isRoot() const {
    return parentDirectoryId.isEmpty;
  }

  Json toJson() const {
    auto jFeatures = Json.emptyArray;
    foreach (f; features)
      jFeatures ~= Json(enumName(f));

    return entityToJson()
      .set("globalAccountId", globalAccountId.value)
      .set("parentDirectoryId", parentDirectoryId.value)
      .set("displayName", displayName)
      .set("description", description)
      .set("status", enumName(status))
      .set("features", jFeatures)
      .set("manageEntitlements", manageEntitlements)
      .set("manageAuthorizations", manageAuthorizations)
      .set("labels", propertiesToJson(labels))
      .set("customProperties", propertiesToJson(customProperties));
  }
}
