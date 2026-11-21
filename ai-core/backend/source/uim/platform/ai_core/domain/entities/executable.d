/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// An executable is a versioned template (workflow or serving) of a
/// scenario: it declares parameters and input/output artifact slots.
module uim.platform.ai_core.domain.entities.executable;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct Executable {
  mixin TenantEntity!ExecutableId;

  ResourceGroupId resourceGroupId;
  ScenarioId scenarioId;
  string name;
  string description;
  ExecutableType type = ExecutableType.workflow;
  string versionId = "1.0.0";
  ParameterDef[] parameters;
  ArtifactSlot[] inputArtifacts;
  ArtifactSlot[] outputArtifacts;
  Label[] labels;

  /// Serving executables can be deployed, workflows executed.
  bool deployable() const {
    return type == ExecutableType.serving;
  }

  void validate() const {
    requireResourceId(id.value, "Executable ID");
    requireText(scenarioId.value, "Scenario ID");
    requireText(name, "Executable name");
    requireMaxLength(name, 256, "Executable name");
    requireText(versionId, "Version");
    string[] seen;
    foreach (p; parameters) {
      if (!isValidBindingKey(p.key))
        throw AiCoreException.invalid("Invalid parameter key '" ~ p.key ~ "'");
      if (seen.canFind(p.key))
        throw AiCoreException.invalid("Duplicate parameter '" ~ p.key ~ "'");
      seen ~= p.key;
    }
    foreach (slots; [inputArtifacts, outputArtifacts]) {
      string[] keys;
      foreach (s; slots) {
        if (!isValidBindingKey(s.key))
          throw AiCoreException.invalid("Invalid artifact key '" ~ s.key ~ "'");
        if (keys.canFind(s.key))
          throw AiCoreException.invalid("Duplicate artifact key '" ~ s.key ~ "'");
        keys ~= s.key;
      }
    }
  }
}

///
unittest {
  Executable e;
  e.id = ExecutableId("trainer");
  e.scenarioId = ScenarioId("s1");
  e.name = "Trainer";
  e.parameters = [ParameterDef("epochs", "string", "10"), ParameterDef("lr")];
  e.validate();
  e.parameters ~= ParameterDef("lr");
  assert(failsWith(AiCoreErrorKind.invalid, () { e.validate(); }));
}
