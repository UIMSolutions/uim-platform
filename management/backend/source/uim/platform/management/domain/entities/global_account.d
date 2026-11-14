/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.entities.global_account;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// A global account is the top-level entity in the SAP BTP account model.
/// It represents a contract with SAP and contains directories and subaccounts.
struct GlobalAccount {
  mixin TenantEntity!GlobalAccountId;

  string displayName;
  string description;
  string contractNumber;
  LicenseType licenseType = LicenseType.enterprise;
  GlobalAccountStatus status = GlobalAccountStatus.active;
  string region; // e.g. "eu10", "us10"
  string costCenter;
  string companyName;
  string contactEmail;
  int maxSubaccounts = 100;
  int currentSubaccounts = 0; // derived — filled by the application layer
  int maxDirectories = 20;
  int currentDirectories = 0; // derived — filled by the application layer
  string[] enabledServices; // list of entitled service names
  long renewalDate; // stdTime, 0 = none
  string[string] customProperties;

  bool isActive() const {
    return status == GlobalAccountStatus.active;
  }

  /// active → suspended
  void suspend(UserId by) {
    if (status != GlobalAccountStatus.active)
      throw new InvalidStateTransition("Global account", enumName(status), "be suspended");
    status = GlobalAccountStatus.suspended;
    update(by);
  }

  /// suspended → active
  void reactivate(UserId by) {
    if (status != GlobalAccountStatus.suspended)
      throw new InvalidStateTransition("Global account", enumName(status), "be reactivated");
    status = GlobalAccountStatus.active;
    update(by);
  }

  /// Throws LimitExceeded if no further subaccount may be created.
  void ensureSubaccountCapacity(size_t existing) const {
    if (maxSubaccounts > 0 && existing >= maxSubaccounts)
      throw new LimitExceeded("Global account '" ~ displayName ~ "' reached its limit of "
          ~ maxSubaccounts.to!string ~ " subaccounts");
  }

  /// Throws LimitExceeded if no further directory may be created.
  void ensureDirectoryCapacity(size_t existing) const {
    if (maxDirectories > 0 && existing >= maxDirectories)
      throw new LimitExceeded("Global account '" ~ displayName ~ "' reached its limit of "
          ~ maxDirectories.to!string ~ " directories");
  }

  Json toJson() const {
    return entityToJson()
      .set("displayName", displayName)
      .set("description", description)
      .set("contractNumber", contractNumber)
      .set("licenseType", enumName(licenseType))
      .set("status", enumName(status))
      .set("region", region)
      .set("costCenter", costCenter)
      .set("companyName", companyName)
      .set("contactEmail", contactEmail)
      .set("maxSubaccounts", maxSubaccounts)
      .set("currentSubaccounts", currentSubaccounts)
      .set("maxDirectories", maxDirectories)
      .set("currentDirectories", currentDirectories)
      .set("enabledServices", listToJson(enabledServices))
      .set("renewalDate", renewalDate)
      .set("customProperties", propertiesToJson(customProperties));
  }
}

///
unittest {
  mixin(ShowTest!("GlobalAccount"));

  auto ga = GlobalAccount(TenantId("t1"));
  ga.displayName = "ACME";
  ga.suspend(UserId("admin"));
  assert(ga.status == GlobalAccountStatus.suspended);

  bool failed;
  try
    ga.suspend(UserId("admin"));
  catch (InvalidStateTransition)
    failed = true;
  assert(failed);

  ga.reactivate(UserId("admin"));
  assert(ga.isActive);

  ga.maxSubaccounts = 1;
  failed = false;
  try
    ga.ensureSubaccountCapacity(1);
  catch (LimitExceeded)
    failed = true;
  assert(failed);
}
