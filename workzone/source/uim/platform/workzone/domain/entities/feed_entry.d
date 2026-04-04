/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.feed_entry;

import uim.platform.workzone.domain.types;

/// An activity feed entry — records actions and events in a workspace.
struct FeedEntry {
  FeedEntryId id;
  WorkspaceId workspaceId;
  TenantId tenantId;
  UserId actorId;
  string actorName;
  string action; // e.g., "created", "updated", "commented", "joined"
  string objectType; // e.g., "content", "workspace", "task"
  string objectId;
  string objectTitle;
  string message;
  string[] mentionedUserIds;
  long createdAt;
}
