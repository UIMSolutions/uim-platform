/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.feed_entry;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// An activity feed entry — records actions and events in a workspace.
struct FeedEntry {
  mixin TenantEntity!(FeedEntryId);

  WorkspaceId workspaceId;
  UserId actorId;
  string actorName;
  string action; // e.g., "created", "updated", "commented", "joined"
  string objectType; // e.g., "content", "workspace", "task"
  string objectId;
  string objectTitle;
  string message;
  string[] mentionedUserIds;

  Json toJson() const {
    return Json.emptyObject
      .set("workspaceId", workspaceId.value)
      .set("actorId", actorId.value)
      .set("actorName", actorName)
      .set("action", action)
      .set("objectType", objectType)
      .set("objectId", objectId)
      .set("objectTitle", objectTitle)
      .set("message", message)
      .set("mentionedUserIds", mentionedUserIds.array);
  }
}
