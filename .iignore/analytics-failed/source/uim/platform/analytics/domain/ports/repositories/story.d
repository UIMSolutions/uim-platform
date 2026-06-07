/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.domain.repositories.story;
// import uim.platform.analytics.domain.entities.story;

import uim.platform.analytics;

// mixin(ShowModule!());
@safe:

interface StoryRepository : ITenantRepository!(Story, StoryId) {

  size_t countByOwner(TenantId tenantId, EntityId ownerId);
  Story[] findByOwner(TenantId tenantId, EntityId ownerId);
  void removeByOwner(TenantId tenantId, EntityId ownerId);

}
