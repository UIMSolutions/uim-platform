/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.knowledge_base_article;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A knowledge base article: draft → review → published (versioned) → archived.
struct KnowledgeBaseArticle {
  mixin TenantEntity!KBArticleId;

  WorkspaceId workspaceId;
  string workspaceName;
  string title;
  string body_;
  string summary;
  UserId authorId;
  string authorName;
  KBArticleStatus status = KBArticleStatus.draft;
  string category;
  string[] tags;
  string[] relatedArticleIds;
  string language = "en";
  int viewCount;
  int helpfulCount;
  int version_; /// "version": increased by every publication
  long publishedAt;
}
