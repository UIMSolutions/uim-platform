/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.feeds;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.feed_entry;

interface FeedRepository {
  FeedEntry[] findByWorkspace(WorkspaceId workspacetenantId, id tenantId);
  FeedEntry* findById(FeedEntryId tenantId, id tenantId);
  FeedEntry[] findByActor(UserId actortenantId, id tenantId);
  void save(FeedEntry entry);
  void remove(FeedEntryId tenantId, id tenantId);
}
