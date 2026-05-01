/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.infrastructure.persistence.memory.prompt;

import uim.platform.ai_launchpad.domain.ports.repositories.prompts;
import uim.platform.ai_launchpad.domain.entities.prompt : Prompt;
import uim.platform.ai_launchpad.domain.types;

class MemoryPromptRepository : IPromptRepository {
  private Prompt[string] store;

  void save(Prompt p) {
    store[p.id] = p;
  }

  Prompt findById(PromptId id) {
    if (auto p = id in store) return *p;
    return Prompt.init;
  }

  Prompt[] findByCollection(PromptCollectionId collectionId) {
    Prompt[] result;
    foreach (p; findAll) {
      if (p.collectionId == collectionId) result ~= p;
    }
    return result;
  }

  Prompt[] findByStatus(PromptStatus status) {
    Prompt[] result;
    foreach (p; findAll) {
      if (p.status == status) result ~= p;
    }
    return result;
  }

  Prompt[] findAll() {
    return store.values;
  }

  void remove(PromptId id) {
    store.removeById(id);
  }
}
