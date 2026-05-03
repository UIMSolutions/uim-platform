/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.forum_topic;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A forum topic / discussion thread within a workspace.
struct ForumTopic {
  mixin TenantEntity!(ForumTopicId);

  WorkspaceId workspaceId;
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

  Json toJson() const {
      return entityToJson
          .set("workspaceId", workspaceId.value)
          .set("title", title)
          .set("body", body_)
          .set("authorId", authorId.value)
          .set("authorName", authorName)
          .set("status", status.to!string())
          .set("tags", tags.toJson)
          .set("replyCount", replyCount)
          .set("viewCount", viewCount)
          .set("likeCount", likeCount)
          .set("pinned", pinned)
          .set("locked", locked)
          .set("lastReplyAt", lastReplyAt);
  }
}
