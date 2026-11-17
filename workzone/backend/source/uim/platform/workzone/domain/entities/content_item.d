/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.content_item;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Blog post, wiki page, announcement or document of a workspace.
struct ContentItem {
  mixin TenantEntity!ContentId;

  WorkspaceId workspaceId;
  string workspaceName;
  string title;
  string body_;
  string summary;
  ContentType contentType = ContentType.blogPost;
  ContentStatus status = ContentStatus.draft;
  UserId authorId;
  string authorName;
  string[] tags;
  string[] attachmentUrls;
  string language = "en";
  int viewCount;
  int likeCount;
  bool pinned;
  bool commentsEnabled = true;
  long publishedAt;
}
