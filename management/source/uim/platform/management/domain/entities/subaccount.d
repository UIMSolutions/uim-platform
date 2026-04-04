/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.entities.subaccount;

// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// A subaccount is the primary organizational unit where cloud services
/// and applications are deployed. It is always part of a global account
/// and optionally part of a directory.
struct Subaccount {
  SubaccountId id;
  GlobalAccountId globalAccountId;
  DirectoryId parentDirectoryId; // empty if directly under global account
  string displayName;
  string description;
  string subdomain; // unique subdomain slug
  string region; // e.g. "eu10", "us10", "ap21"
  SubaccountStatus status = SubaccountStatus.active;
  SubaccountUsage usage = SubaccountUsage.unset;
  bool betaEnabled = false;
  bool usedForProduction = false;
  string technicalName;
  TenantId tenantId; // associated identity tenant
  long createdAt;
  long modifiedAt;
  string createdBy;
  string[string] labels;
  string[string] customProperties;
}
