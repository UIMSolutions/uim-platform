/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.application.dtos.module_;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

struct ModuleSpec {
  ModuleType moduleType = ModuleType.custom;
  /// Only for custom modules; known modules are named after their type.
  string name;
  string description;
  /// "" = current release of the channel
  string version_;
  ModuleChannel channel = ModuleChannel.regular;
  string customResourcePolicy = "CreateAndDelete";
  string configurationJson;
}

alias EnableModuleRequest = CreateRequest!(KymaEnvironmentId, ModuleSpec);
alias UpdateModuleRequest = UpdateRequest!(KymaModuleId, ModuleSpec);
