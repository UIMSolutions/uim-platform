/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A scenario groups the executables, configurations and artifacts of one
/// AI use case (e.g. "invoice-classification").
module uim.platform.ai_core.domain.entities.scenario;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

struct Scenario {
  mixin TenantEntity!ScenarioId;

  ResourceGroupId resourceGroupId;
  string name;
  string description;
  Label[] labels;

  void validate() const {
    requireResourceId(id.value, "Scenario ID");
    requireText(name, "Scenario name");
    requireMaxLength(name, 256, "Scenario name");
    requireMaxLength(description, 5000, "Description");
    foreach (l; labels)
      if (!isValidLabel(l))
        throw AiCoreException.invalid("Invalid label '" ~ l.key ~ "'");
  }
}
