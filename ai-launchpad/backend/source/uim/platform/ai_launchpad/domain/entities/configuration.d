/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A configuration binds an executable of a scenario to parameter values
/// and input artifacts (datasets or models). Like in SAP AI Core it is
/// immutable once an execution or deployment uses it.
module uim.platform.ai_launchpad.domain.entities.configuration;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct Configuration {
  mixin TenantEntity!ConfigurationId;

  ScenarioId scenarioId;
  ConnectionId connectionId; /// derived from the scenario
  string name;
  string executableId;
  string[] parameters; /// "key=value"
  string[] inputArtifacts; /// "key=<dataset or model id>"

  /// The artifact ids referenced by the input bindings.
  string[] artifactIds() const {
    return inputArtifacts.map!(b => labelValue(b)).array;
  }

  void validate() const {
    requireId(id.value, "Configuration ID");
    requireId(scenarioId.value, "Scenario");
    requireText(name, "Configuration name");
    requireMaxLength(name, 200, "Configuration name");
    requireId(executableId, "Executable");
    requireLabels(parameters, "Parameter");
    requireLabels(inputArtifacts, "Input artifact");
    foreach (b; inputArtifacts)
      requireId(labelValue(b), "Input artifact");
    requireUniqueKeys(parameters, "parameter");
    requireUniqueKeys(inputArtifacts, "input artifact");
  }
}

///
unittest {
  Configuration c;
  c.id = ConfigurationId("cfg");
  c.scenarioId = ScenarioId("s");
  c.name = "Training";
  c.executableId = "training";
  c.parameters = ["epochs=10", "lr=0.01"];
  c.inputArtifacts = ["trainingData=ds-1"];
  c.validate();
  assert(c.artifactIds == ["ds-1"]);
  c.parameters = ["epochs=10", "epochs=20"];
  assert(failsWith(AilpErrorKind.invalid, () { c.validate(); }));
}
