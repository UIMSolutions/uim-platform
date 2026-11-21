/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A configuration binds the parameters and input artifacts of an
/// executable. It is immutable once created (AI API semantics) and is the
/// starting point of executions and deployments.
module uim.platform.ai_core.domain.entities.configuration;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct Configuration {
  mixin TenantEntity!ConfigurationId;

  ResourceGroupId resourceGroupId;
  ScenarioId scenarioId;
  ExecutableId executableId;
  string name;
  Label[] parameterBindings;
  ArtifactRef[] inputArtifactBindings;

  void validate() const {
    requireText(name, "Configuration name");
    requireMaxLength(name, 256, "Configuration name");
    requireText(scenarioId.value, "Scenario ID");
    requireText(executableId.value, "Executable ID");
  }
}
