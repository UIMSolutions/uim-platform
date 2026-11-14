/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.enumerations.modules;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Status of a Kyma module.
enum ModuleStatus {
  installing,
  enabled,
  uninstalling,
  disabled,
  error,
}

/// Release channel of a module.
enum ModuleChannel {
  regular,
  fast,
}

/// Kyma modules known to the service.
enum ModuleType : string {
  istio = "istio",
  apiGateway = "api-gateway",
  btpOperator = "btp-operator",
  serverless = "serverless",
  eventing = "eventing",
  nats = "nats",
  telemetry = "telemetry",
  keda = "keda",
  connectivityProxy = "connectivity-proxy",
  applicationConnector = "application-connector",
  custom = "custom",
}

/// True if the module counts as active for dependency checks.
bool isActive(ModuleStatus s) pure nothrow {
  return s == ModuleStatus.enabled || s == ModuleStatus.installing;
}

///
unittest {
  assert(parseEnum!ModuleType("api-gateway", ModuleType.custom) == ModuleType.apiGateway);
  assert(parseEnum!ModuleType("btpOperator", ModuleType.custom) == ModuleType.btpOperator);
  assert(ModuleStatus.installing.isActive && !ModuleStatus.disabled.isActive);
}
