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
