/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.feeds;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.feed_entry;
// import uim.platform.workzone.domain.ports.repositories.feeds;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
// import std.algorithm : filter;
// import std.array : array;

class MemoryFeedRepository : TenantRepository!(FeedEntry, FeedEntryId), FeedRepository {

  size_t countByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByWorkspace(tenantId, workspaceId).length;
  }
  FeedEntry[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByTenant(tenantId).filter!(e => e.workspaceId == workspaceId).array;
  }
  void removeByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByWorkspace(tenantId, workspaceId).each!(e => remove(e));
  }

  size_t countByActor(TenantId tenantId, UserId actorId) {
    return findByActor(tenantId, actorId).length;
  }
  FeedEntry[] findByActor(TenantId tenantId, UserId actorId) {
    return findByTenant(tenantId).filter!(e => e.actorId == actorId).array;
  }
  void removeByActor(TenantId tenantId, UserId actorId) {
    return findByActor(tenantId, actorId).each!(e => remove(e));
  }

}
