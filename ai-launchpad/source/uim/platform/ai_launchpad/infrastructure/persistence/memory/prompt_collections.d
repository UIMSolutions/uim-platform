/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.prompt_collections;

import uim.platform.ai_launchpad.domain.ports.repositories.prompt_collections;
import uim.platform.ai_launchpad.domain.entities.prompt_collection : PromptCollection;
import uim.platform.ai_launchpad.domain.types;

class MemoryPromptCollectionRepository : IPromptCollectionRepository {
  private PromptCollection[string] store;

  void save(PromptCollection pc) {
    store[pc.id] = pc;
  }

  PromptCollection findById(PromptCollectionId id) {
    if (auto p = id in store) return *p;
    return PromptCollection.init;
  }

  PromptCollection[] findByWorkspace(WorkspaceId workspaceId) {
    PromptCollection[] result;
    foreach (pc; store) {
      if (pc.workspaceId == workspaceId) result ~= pc;
    }
    return result;
  }

  PromptCollection[] findAll() {
    return store.values;
  }

  void remove(PromptCollectionId id) {
    store.remove(id);
  }
}
