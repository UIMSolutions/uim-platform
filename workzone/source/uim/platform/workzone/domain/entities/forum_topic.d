/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.forum_topic;

import uim.platform.workzone.domain.types;

/// A forum topic / discussion thread within a workspace.
struct ForumTopic {
  ForumTopicId id;
  WorkspaceId workspaceId;
  TenantId tenantId;
  string title;
  string body_;
  UserId authorId;
  string authorName;
  ForumTopicStatus status = ForumTopicStatus.open;
  string[] tags;
  int replyCount;
  int viewCount;
  int likeCount;
  bool pinned;
  bool locked;
  long lastReplyAt;
  long createdAt;
  long updatedAt;
}
