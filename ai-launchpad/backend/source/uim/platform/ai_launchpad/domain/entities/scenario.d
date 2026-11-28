/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A scenario (AI use case, e.g. "fraud-detection") synchronised from a
/// runtime, with the executables (training / serving templates) it offers.
module uim.platform.ai_launchpad.domain.entities.scenario;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct Scenario {
  mixin TenantEntity!ScenarioId;

  ConnectionId connectionId;
  string name;
  string description;
  string[] executables; /// ids of the executables (e.g. "training", "serving")
  string[] labels; /// "key=value"

  bool offers(string executableId) const {
    return executables.length == 0 || executables.canFind(executableId);
  }

  void validate() const {
    requireId(id.value, "Scenario ID");
    requireId(connectionId.value, "Connection");
    requireText(name, "Scenario name");
    requireMaxLength(name, 200, "Scenario name");
    requireMaxLength(description, 4000, "Description");
    foreach (e; executables)
      requireId(e, "Executable");
    requireLabels(labels, "Scenario label");
  }
}

///
unittest {
  Scenario s;
  s.id = ScenarioId("fraud");
  s.connectionId = ConnectionId("c");
  s.name = "Fraud detection";
  s.executables = ["training", "serving"];
  s.validate();
  assert(s.offers("training") && !s.offers("batch"));
  s.executables = ["bad id"];
  assert(failsWith(AilpErrorKind.invalid, () { s.validate(); }));
}
