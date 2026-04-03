/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.content_item;

import uim.platform.workzone.domain.types;

/// A content item within a workspace — blog, wiki, KB article, forum post, etc.
struct ContentItem
{
  ContentId id;
  WorkspaceId workspaceId;
  TenantId tenantId;
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
  long createdAt;
  long updatedAt;
}
