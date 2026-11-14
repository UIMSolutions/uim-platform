/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.ports.gateways.provisioning;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Outcome of a call to a provisioning back end.
struct ProvisioningResult {
  bool success;
  string message;
  /// Platform specific key (e.g. CF org GUID, Kyma cluster name)
  string technicalKey;
  /// Dashboard / application URL
  string url;
}

/// Driven port: the runtimes and SaaS providers that actually provision
/// environments and subscriptions (CF cloud controller, Kyma KEB, SaaS registry).
interface IProvisioningGateway {
  ProvisioningResult provisionEnvironment(const Environment environment, const Subaccount subaccount);
  ProvisioningResult deprovisionEnvironment(const Environment environment);
  ProvisioningResult subscribe(const Subscription subscription, const Subaccount subaccount);
  ProvisioningResult unsubscribe(const Subscription subscription);
}
