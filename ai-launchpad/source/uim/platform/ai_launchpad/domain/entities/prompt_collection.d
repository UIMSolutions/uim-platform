/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.entities.prompt_collection;

// import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct PromptCollection {
  mixin TenantEntity!PromptCollectionId;

  string name;
  string description;
  ScenarioId scenarioId;
  WorkspaceId workspaceId;
  int promptCount;
  
  Json toJson() const {
    return entityToJson()
      .set("name", name)
      .set("description", description)
      .set("scenarioId", scenarioId.value)
      .set("workspaceId", workspaceId.value)
      .set("promptCount", promptCount);
  }
}
