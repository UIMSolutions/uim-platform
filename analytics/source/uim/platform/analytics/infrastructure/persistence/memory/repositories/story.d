/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.persistence.memory.repositories.story;

import uim.platform.analytics.domain.entities.story;
import uim.platform.analytics.domain.repositories.story;
import uim.platform.analytics.domain.values.common;

class MemoryStoryRepository : StoryRepository {
  private Story[string] store;

  Story findById(EntityId id) {
    if (auto p = id.value in store)
      return *p;
    return null;
  }

  Story[] findByOwner(EntityId ownerId) {
    Story[] result;
    foreach (s; store.byValue())
      if (s.ownerId == ownerId)
        result ~= s;
    return result;
  }

  Story[] findAll() {
    return store.values;
  }

  void save(Story story) {
    store[story.id.value] = story;
  }

  void remove(EntityId id) {
    store.remove(id.value);
  }
}
