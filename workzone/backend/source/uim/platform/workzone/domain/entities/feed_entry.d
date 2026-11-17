/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.feed_entry;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// An activity stream entry of a workspace ("Jane published 'Q4 plan'").
struct FeedEntry {
  mixin TenantEntity!FeedEntryId;

  WorkspaceId workspaceId;
  string workspaceName;
  UserId actorId;
  string actorName;
  string action; /// created | published | joined | replied | ...
  string objectType; /// content | forumTopic | event | ...
  string objectId;
  string objectTitle;
  string message;
  string[] mentionedUserIds;
}
