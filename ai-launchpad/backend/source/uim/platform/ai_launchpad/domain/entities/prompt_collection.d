/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A collection of prompts of a workspace (generative AI hub).
module uim.platform.ai_launchpad.domain.entities.prompt_collection;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct PromptCollection {
  mixin TenantEntity!PromptCollectionId;

  WorkspaceId workspaceId;
  string name;
  string description;

  void validate() const {
    requireId(id.value, "Prompt collection ID");
    requireId(workspaceId.value, "Workspace");
    requireText(name, "Collection name");
    requireMaxLength(name, 200, "Collection name");
    requireMaxLength(description, 2000, "Description");
  }
}

///
unittest {
  PromptCollection c;
  c.id = PromptCollectionId("support");
  c.workspaceId = WorkspaceId("ml");
  c.name = "Customer support";
  c.validate();
}
