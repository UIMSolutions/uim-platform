/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.infrastructure.clients.simulated_provisioning;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Provisioning gateway adapter that simulates the runtimes and SaaS providers:
/// provisioning succeeds immediately and returns deterministic keys and URLs.
/// Swap for real HTTP clients (CF Cloud Controller, Kyma KEB, SaaS registry).
class SimulatedProvisioningClient : IProvisioningGateway {
  protected string baseDomain;

  this(string baseDomain = "cfapps.example.com") {
    this.baseDomain = baseDomain;
  }

  ProvisioningResult provisionEnvironment(const Environment environment, const Subaccount subaccount) {
    auto shortId = environment.id.value.length >= 8 ? environment.id.value[0 .. 8] : environment.id.value;
    auto region = subaccount.region.length > 0 ? subaccount.region : "eu10";
    final switch (environment.environmentType) {
    case EnvironmentType.cloudFoundry:
      return ProvisioningResult(true, "", "cf-org-" ~ shortId,
        "https://api.cf." ~ region ~ ".hana.ondemand.com/orgs/" ~ subaccount.subdomain);
    case EnvironmentType.kyma:
      return ProvisioningResult(true, "", "kyma-" ~ shortId,
        "https://console." ~ shortId ~ ".kyma.ondemand.com");
    case EnvironmentType.abap:
      return ProvisioningResult(true, "", "abap-" ~ shortId,
        "https://" ~ subaccount.subdomain ~ ".abap." ~ region ~ ".hana.ondemand.com");
    case EnvironmentType.neo:
      return ProvisioningResult(false, "The Neo environment is no longer available for new subaccounts");
    }
  }

  ProvisioningResult deprovisionEnvironment(const Environment environment) {
    return ProvisioningResult(true);
  }

  ProvisioningResult subscribe(const Subscription subscription, const Subaccount subaccount) {
    return ProvisioningResult(true, "", subscription.appName,
      "https://" ~ subaccount.subdomain ~ "." ~ subscription.appName ~ "." ~ baseDomain);
  }

  ProvisioningResult unsubscribe(const Subscription subscription) {
    return ProvisioningResult(true);
  }
}

///
unittest {
  mixin(ShowTest!("SimulatedProvisioningClient"));

  auto c = new SimulatedProvisioningClient();
  auto sub = Subaccount(TenantId("t"));
  sub.subdomain = "dev";
  auto env = Environment(TenantId("t"));
  assert(c.provisionEnvironment(env, sub).success);
  env.environmentType = EnvironmentType.neo;
  assert(!c.provisionEnvironment(env, sub).success);
}
