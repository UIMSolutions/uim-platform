/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.entities.environment;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// An environment instance represents a provisioned runtime environment
/// (Cloud Foundry org, Kyma cluster, ABAP system, etc.) within a subaccount.
struct Environment {
  mixin TenantEntity!EnvironmentId;

  GlobalAccountId globalAccountId;
  SubaccountId subaccountId;
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
  string[string] parameters; // provisioning parameters
  string[string] labels;

  /// True while the environment counts against the subaccount (not being removed / failed).
  bool isLive() const {
    return status != EnvironmentStatus.deleting && status != EnvironmentStatus.error;
  }

  Json toJson() const {
    return entityToJson()
      .set("globalAccountId", globalAccountId.value)
      .set("subaccountId", subaccountId.value)
      .set("name", name)
      .set("description", description)
      .set("environmentType", enumName(environmentType))
      .set("status", enumName(status))
      .set("planName", planName)
      .set("landscapeLabel", landscapeLabel)
      .set("technicalKey", technicalKey)
      .set("dashboardUrl", dashboardUrl)
      .set("platformRegion", platformRegion)
      .set("services", listToJson(services))
      .set("memoryQuotaMb", memoryQuotaMb)
      .set("routeQuota", routeQuota)
      .set("serviceQuota", serviceQuota)
      .set("parameters", propertiesToJson(parameters))
      .set("labels", propertiesToJson(labels));
  }
}

///
unittest {
  mixin(ShowTest!("Environment"));

  // The id must come from the TenantEntity mixin (no shadowing field).
  auto e = Environment(TenantId("t1"));
  assert(e.id.value.length > 0);
  assert(e.toJson()["id"].get!string == e.id.value);
  e.status = EnvironmentStatus.error;
  assert(!e.isLive);
}
