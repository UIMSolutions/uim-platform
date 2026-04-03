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
struct Directory
{
  DirectoryId id;
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
  string createdBy;
  long createdAt;
  long modifiedAt;
  string[string] labels;
  string[string] customProperties;
}
