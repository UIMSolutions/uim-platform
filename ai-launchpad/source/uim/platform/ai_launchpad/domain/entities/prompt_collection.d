/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.entities.prompt_collection;

import uim.platform.ai_launchpad.domain.types;

struct PromptCollection {
  PromptCollectionId id;
  string name;
  string description;
  ScenarioId scenarioId;
  WorkspaceId workspaceId;
  int promptCount;
  string createdAt;
  string modifiedAt;
}
