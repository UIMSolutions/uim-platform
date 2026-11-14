/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.domain.entities.platform;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

/// A registered runtime environment (Cloud Foundry, Kubernetes, Kyma, ...)
/// that consumes services through the service manager.
struct Platform {
  mixin TenantEntity!PlatformId;

  string name;
  string description;
  PlatformType type = PlatformType.other;
  PlatformStatus status = PlatformStatus.active;
  string region;
  SubaccountId subaccountId;
  string brokerUrl; /// callback URL of the platform's broker proxy
  string credentials; /// secret — never returned by adapters

  bool isActive() const {
    return status == PlatformStatus.active;
  }

  void validate() const {
    requireName(name, "Platform");
    if (brokerUrl.length > 0 && !isHttpUrl(brokerUrl))
      throw ServiceManagerException.invalid("Platform brokerUrl must be an http(s) URL");
  }
}

///
unittest {
  Platform p;
  p.name = "cf-eu10";
  p.validate();
  p.brokerUrl = "ftp://x";
  assert(failsWith(ServiceManagerErrorKind.invalid, () { p.validate(); }));
}
