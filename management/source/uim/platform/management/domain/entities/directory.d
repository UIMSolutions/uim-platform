/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.entities.directory;

// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// A directory is a grouping entity within a global account for
/// organizing subaccounts and managing entitlements/authorizations.
struct Directory {
  mixin IdEntity!DirectoryId;

  GlobalAccountId globalAccountId;
  DirectoryId parentDirectoryId; // empty if root-level
  string displayName;
  string description;
  DirectoryStatus status = DirectoryStatus.active;
  DirectoryFeature[] features; // entitlements, authorizations
  string[] subdirectories; // child directory IDs
  string[] subaccounts; // child subaccount IDs
  bool manageEntitlements;
  bool manageAuthorizations;
  string[string] labels;
  string[string] customProperties;

  static Directory createFromRequest(CreateDirectoryRequest req) {
    Directory directory;
    directory.create();

    directory.globalAccountId = req.globalAccountId;
    directory.parentDirectoryId = req.parentDirectoryId;
    directory.displayName = req.displayName;
    directory.description = req.description;
    directory.features = req.features.map!(f => f.to!DirectoryFeature).array;
    directory.manageEntitlements = req.manageEntitlements;
    directory.manageAuthorizations = req.manageAuthorizations;
    directory.createdBy = req.createdBy;
    directory.createdAt = clockSeconds();
    directory.updatedAt = directory.createdAt;
    directory.labels = req.labels;
    directory.customProperties = req.customProperties;
    
    return directory;
  }

  Json toJson() const {
    auto jLabels = Json.emptyObject;
    foreach (key, value; labels) {
      jLabels.set(key, value);
    }

    auto jCustomProps = Json.emptyObject;
    foreach (key, value; customProperties) {
      jCustomProps.set(key, value);
    }

    return entityToJson()
      .set("globalAccountId", globalAccountId.value)
      .set("parentDirectoryId", parentDirectoryId.value)
      .set("displayName", displayName)
      .set("description", description)
      .set("status", status.to!string)
      .set("features", features.map!(f => f.to!string).array.toJson)
      .set("subdirectories", subdirectories.toJson)
      .set("subaccounts", subaccounts.toJson)
      .set("manageEntitlements", manageEntitlements)
      .set("manageAuthorizations", manageAuthorizations)
      .set("labels", jLabels)
      .set("customProperties", jCustomProps);
  }
}
