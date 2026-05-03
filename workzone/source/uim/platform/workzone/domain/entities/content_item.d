/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.content_item;

// import uim.platform.workzone.domain.types;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
/// A content item within a workspace — blog, wiki, KB article, forum post, etc.
struct ContentItem {
  mixin TenantEntity!(ContentId);

  WorkspaceId workspaceId;
  string title;
  string body_; // rich text / markdown body
  string summary;
  ContentType contentType = ContentType.blogPost;
  ContentStatus status = ContentStatus.draft;
  UserId authorId;
  string authorName;
  string[] tags;
  string[] attachmentUrls;
  string language;
  int viewCount;
  int likeCount;
  bool pinned;
  bool commentsEnabled = true;
  long publishedAt;

  Json toJson() const {
      return entityToJson
          .set("workspaceId", workspaceId.value)
          .set("title", title)
          .set("body", body_)
          .set("summary", summary)
          .set("contentType", contentType.to!string())
          .set("status", status.to!string())
          .set("authorId", authorId.value)
          .set("authorName", authorName)
          .set("tags", tags.toJson)
          .set("attachmentUrls", attachmentUrls.toJson)
          .set("language", language)
          .set("viewCount", viewCount)
          .set("likeCount", likeCount)
          .set("pinned", pinned)
          .set("commentsEnabled", commentsEnabled)
          .set("publishedAt", publishedAt);
  }
}
