/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.domain.ports.prompt_collection_repository;

import uim.platform.ai_launchpad.domain.types;
import uim.platform.ai_launchpad.domain.entities.prompt_collection : PromptCollection;

interface IPromptCollectionRepository {
  void save(PromptCollection pc);
  PromptCollection findById(PromptCollectionId id);
  PromptCollection[] findByWorkspace(WorkspaceId workspaceId);
  PromptCollection[] findAll();
  void remove(PromptCollectionId id);
}
