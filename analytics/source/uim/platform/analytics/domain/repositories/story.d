/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.repositories.story;

import uim.platform.analytics.domain.entities.story;
import uim.platform.analytics.domain.values.common;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:

interface StoryRepository
{
  Story findById(EntityId id);
  Story[] findByOwner(EntityId ownerId);
  Story[] findAll();
  void save(Story story);
  void remove(EntityId id);
}
