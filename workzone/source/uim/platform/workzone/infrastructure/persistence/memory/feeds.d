/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.feed_repo;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.feed_entry;
import uim.platform.workzone.domain.ports.repositories.feeds;

// import std.algorithm : filter;
// import std.array : array;

class MemoryFeedRepository : FeedRepository {
  private FeedEntry[FeedEntryId] store;

  FeedEntry[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.workspaceId == workspaceId)
      .array;
  }

  FeedEntry* findById(FeedEntryId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  FeedEntry[] findByActor(UserId actorId, TenantId tenantId) {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.actorId == actorId).array;
  }

  void save(FeedEntry entry) {
    store[entry.id] = entry;
  }

  void remove(FeedEntryId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
