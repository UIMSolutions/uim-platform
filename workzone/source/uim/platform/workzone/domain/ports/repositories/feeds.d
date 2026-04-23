/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.feeds;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.feed_entry;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
interface FeedRepository : ITenantRepository!(FeedEntry, FeedEntryId) {

  size_t countByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  FeedEntry[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  void removeByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  
  size_t countByActor(TenantId tenantId, UserId actorId);
  FeedEntry[] findByActor(TenantId tenantId, UserId actorId);
  void removeByActor(TenantId tenantId, UserId actorId);

}
