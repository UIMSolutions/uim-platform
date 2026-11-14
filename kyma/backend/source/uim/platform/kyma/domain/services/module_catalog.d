/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.services.module_catalog;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Modules a module depends on (must be active before it can be enabled).
ModuleType[] dependenciesOf(ModuleType type) pure {
  switch (type) {
  case ModuleType.apiGateway, ModuleType.connectivityProxy:
    return [ModuleType.istio];
  case ModuleType.eventing:
    return [ModuleType.nats];
  case ModuleType.applicationConnector:
    return [ModuleType.istio, ModuleType.eventing];
  default:
    return null;
  }
}

/// Modules every new Kyma runtime starts with.
immutable ModuleType[] defaultModules = [ModuleType.istio, ModuleType.apiGateway, ModuleType.btpOperator];

/// The current release of a module per channel.
string defaultVersionOf(ModuleType type, ModuleChannel channel) pure {
  bool fast = channel == ModuleChannel.fast;
  switch (type) {
  case ModuleType.istio:
    return fast ? "1.12.0" : "1.11.1";
  case ModuleType.apiGateway:
    return fast ? "3.1.0" : "3.0.2";
  case ModuleType.btpOperator:
    return fast ? "1.2.0" : "1.1.18";
  case ModuleType.serverless:
    return fast ? "1.6.0" : "1.5.1";
  case ModuleType.eventing:
    return fast ? "1.4.0" : "1.3.2";
  case ModuleType.nats:
    return fast ? "1.2.0" : "1.1.5";
  case ModuleType.telemetry:
    return fast ? "1.32.0" : "1.31.0";
  case ModuleType.keda:
    return fast ? "1.6.0" : "1.5.2";
  case ModuleType.connectivityProxy:
    return fast ? "1.1.0" : "1.0.7";
  case ModuleType.applicationConnector:
    return fast ? "1.2.0" : "1.1.11";
  default:
    return "0.0.1";
  }
}

/// The module a workload kind needs in its environment.
enum WorkloadKind {
  function_,
  apiRule,
  subscription,
  serviceInstance,
  application,
}

ModuleType requiredModuleFor(WorkloadKind kind) pure nothrow {
  final switch (kind) {
  case WorkloadKind.function_:
    return ModuleType.serverless;
  case WorkloadKind.apiRule:
    return ModuleType.apiGateway;
  case WorkloadKind.subscription:
    return ModuleType.eventing;
  case WorkloadKind.serviceInstance:
    return ModuleType.btpOperator;
  case WorkloadKind.application:
    return ModuleType.applicationConnector;
  }
}

/// Domain service: dependency checks for enabling and disabling modules.
class ModuleDependencyResolver {
  /// Names of required modules that are not active in `installed`.
  string[] missingDependencies(const ref KymaModule mod, const KymaModule[] installed) {
    string[] missing;
    foreach (req; mod.requiredModules)
      if (!installed.any!(m => m.name == req && m.status.isActive))
        missing ~= req;
    return missing;
  }

  /// Names of active modules that depend on `moduleName`.
  string[] dependents(string moduleName, const KymaModule[] installed) {
    string[] result;
    foreach (m; installed)
      if (m.status.isActive && m.requiredModules.canFind(moduleName))
        result ~= m.name;
    return result;
  }
}

///
unittest {
  assert(dependenciesOf(ModuleType.apiGateway) == [ModuleType.istio]);
  assert(requiredModuleFor(WorkloadKind.function_) == ModuleType.serverless);

  KymaModule istio, gw;
  istio.name = "istio";
  istio.status = ModuleStatus.enabled;
  gw.name = "api-gateway";
  gw.requiredModules = ["istio"];
  gw.status = ModuleStatus.enabled;

  auto r = new ModuleDependencyResolver();
  assert(r.missingDependencies(gw, [istio]).length == 0);
  assert(r.missingDependencies(gw, []) == ["istio"]);
  assert(r.dependents("istio", [istio, gw]) == ["api-gateway"]);
}
