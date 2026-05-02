/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.domain.entities.scenario;

// import uim.platform.ai_core.domain.types;
import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
struct Scenario {
  mixin TenantEntity!(ScenarioId);

  ResourceGroupId resourceGroupId;
  string name;
  string description;
  string[] labels;

  Json toJson() const {
      return entityToJson
          .set("resourceGroupId", resourceGroupId.value)
          .set("name", name)
          .set("description", description)
          .set("labels", labels.map!(l => l.toJson()).array.toJson);
  }
}
