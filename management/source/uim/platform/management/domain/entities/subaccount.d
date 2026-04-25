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
  mixin TenantEntity!(SubaccountId);

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
  string[string] labels;
  string[string] customProperties;

  Json toJson() const {
    auto jLabels = Json.emptyObject;
    foreach (key, value; labels) {
      jLabels.set(key, value);
    }

    auto jCustomProps = Json.emptyObject;
    foreach (key, value; customProperties) {
      jCustomProps.set(key, value);
    }

    return entityToJson
      .set("globalAccountId", globalAccountId.value)
      .set("parentDirectoryId", parentDirectoryId.value)
      .set("displayName", displayName)
      .set("description", description)
      .set("subdomain", subdomain)
      .set("region", region)
      .set("status", status.to!string)
      .set("usage", usage.to!string)
      .set("betaEnabled", betaEnabled)
      .set("usedForProduction", usedForProduction)
      .set("technicalName", technicalName)
      .set("labels", jLabels)
      .set("customProperties", jCustomProps);
  }
}
