/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.entities.global_account;

// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// A global account is the top-level entity in the SAP BTP account model.
/// It represents a contract with SAP and contains directories and subaccounts.
struct GlobalAccount {
  GlobalAccountId globalAccountId;
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
  int currentSubaccounts = 0;
  int maxDirectories = 20;
  int currentDirectories = 0;
  string[] enabledServices; // list of entitled service names
  long renewalDate;
  long createdAt;
  long modifiedAt;
  string createdBy;
  string[string] customProperties;
}
