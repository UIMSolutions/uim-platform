/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.infrastructure.persistence.repositories.repositories.stories;
// import uim.platform.analytics.domain.entities.story;
// import uim.platform.analytics.domain.repositories.story;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
class MemoryStoryRepository : TenantRepository!(Story, StoryId), StoryRepository {

  size_t countByOwner(TenantId tenantId, EntityId ownerId) {
    return findByOwner(tenantId, ownerId).length;
  }

  Story[] findByOwner(TenantId tenantId, EntityId ownerId) {
    return findByTenant(tenantId).filter!(s => s.ownerId == ownerId).array;
  }

  void removeByOwner(TenantId tenantId, EntityId ownerId) {
    foreach (s; findByOwner(tenantId, ownerId))
      remove(s);
  }
}
