/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.entities.module_;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// A Kyma module (istio, serverless, eventing, ...) enabled in an environment.
struct KymaModule {
  mixin TenantEntity!KymaModuleId;

  KymaEnvironmentId environmentId;
  ModuleType moduleType = ModuleType.custom;
  /// The module name — equals the module type except for custom modules.
  string name;
  string description;
  ModuleStatus status = ModuleStatus.installing;

  string version_;
  ModuleChannel channel = ModuleChannel.regular;
  /// "CreateAndDelete" (Kyma manages the default CR) or "Ignore".
  string customResourcePolicy = "CreateAndDelete";
  /// Module configuration (JSON text, the module CR spec).
  string configurationJson;
  /// Names of modules this module depends on.
  string[] requiredModules;
}
