/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.entities.environment_instance;

// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// An environment instance represents a provisioned runtime environment
/// (Cloud Foundry org, Kyma cluster, ABAP system, etc.) within a subaccount.
struct EnvironmentInstance {
  EnvironmentInstanceId id;
  SubaccountId subaccountId;
  GlobalAccountId globalAccountId;
  string name;
  string description;
  EnvironmentType environmentType = EnvironmentType.cloudFoundry;
  EnvironmentStatus status = EnvironmentStatus.creating;
  string planName; // e.g. "standard", "trial", "free"
  string landscapeLabel; // e.g. "cf-eu10", "kyma-eu10"
  string technicalKey; // platform-specific key (CF org GUID, etc.)
  string dashboardUrl; // URL to the environment dashboard
  string platformRegion;
  string[] services; // enabled services within this environment
  int memoryQuotaMb = 0; // for CF: org memory quota
  int routeQuota = 0;
  int serviceQuota = 0;
  string createdBy;
  long createdAt;
  long modifiedAt;
  string[string] parameters; // provisioning parameters
  string[string] labels;
}
