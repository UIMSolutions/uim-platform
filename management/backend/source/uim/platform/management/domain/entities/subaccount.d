/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.entities.subaccount;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// A subaccount is the primary organizational unit where cloud services
/// and applications are deployed. It is always part of a global account
/// and optionally part of a directory.
struct Subaccount {
  mixin TenantEntity!SubaccountId;

  GlobalAccountId globalAccountId;
  DirectoryId parentDirectoryId; // empty if directly under global account
  string displayName;
  string description;
  string subdomain; // unique subdomain slug (per tenant)
  string region; // e.g. "eu10", "us10", "ap21"
  SubaccountStatus status = SubaccountStatus.active;
  SubaccountUsage usage = SubaccountUsage.unset;
  bool betaEnabled = false;
  bool usedForProduction = false;
  string technicalName;
  string[string] labels;
  string[string] customProperties;

  bool isActive() const {
    return status == SubaccountStatus.active;
  }

  /// active → suspended
  void suspend(UserId by) {
    if (status != SubaccountStatus.active)
      throw new InvalidStateTransition("Subaccount", enumName(status), "be suspended");
    status = SubaccountStatus.suspended;
    update(by);
  }

  /// suspended → active
  void reactivate(UserId by) {
    if (status != SubaccountStatus.suspended)
      throw new InvalidStateTransition("Subaccount", enumName(status), "be reactivated");
    status = SubaccountStatus.active;
    update(by);
  }

  /// Move below another directory (empty = global account root). Only active subaccounts move.
  void moveTo(DirectoryId target, UserId by) {
    if (status != SubaccountStatus.active)
      throw new InvalidStateTransition("Subaccount", enumName(status), "be moved");
    parentDirectoryId = target;
    update(by);
  }

  Json toJson() const {
    return entityToJson()
      .set("globalAccountId", globalAccountId.value)
      .set("parentDirectoryId", parentDirectoryId.value)
      .set("displayName", displayName)
      .set("description", description)
      .set("subdomain", subdomain)
      .set("region", region)
      .set("status", enumName(status))
      .set("usage", enumName(usage))
      .set("betaEnabled", betaEnabled)
      .set("usedForProduction", usedForProduction)
      .set("technicalName", technicalName)
      .set("labels", propertiesToJson(labels))
      .set("customProperties", propertiesToJson(customProperties));
  }
}

/// True if the value is a valid subdomain: 1-63 chars, lower case letters,
/// digits and hyphens, not starting or ending with a hyphen.
bool isValidSubdomain(string value) pure {
  if (value.length == 0 || value.length > 63 || value[0] == '-' || value[$ - 1] == '-')
    return false;
  foreach (c; value)
    if (!((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '-'))
      return false;
  return true;
}

///
unittest {
  mixin(ShowTest!("Subaccount"));

  auto s = Subaccount(TenantId("t1"));
  s.moveTo(DirectoryId("d1"), UserId("u"));
  assert(s.parentDirectoryId.value == "d1");
  s.suspend(UserId("u"));

  bool failed;
  try
    s.moveTo(DirectoryId("d2"), UserId("u"));
  catch (InvalidStateTransition)
    failed = true;
  assert(failed);

  assert(isValidSubdomain("dev-eu10"));
  assert(!isValidSubdomain("Dev"));
  assert(!isValidSubdomain("-dev"));
  assert(!isValidSubdomain(""));
}
