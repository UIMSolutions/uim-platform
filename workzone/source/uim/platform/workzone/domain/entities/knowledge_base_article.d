/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.knowledge_base_article;

import uim.platform.workzone.domain.types;

/// A knowledge base article — structured documentation within a workspace.
struct KnowledgeBaseArticle {
  mixin TenantEntity!(KBArticleId);

  WorkspaceId workspaceId;
  string title;
  string body_;
  string summary;
  UserId authorId;
  string authorName;
  KBArticleStatus status = KBArticleStatus.draft;
  string category;
  string[] tags;
  string[] relatedArticleIds;
  string language;
  int viewCount;
  int helpfulCount;
  int version_;
  long publishedAt;

  Json toJson() const {
      return entityToJson
          .set("workspaceId", workspaceId.value)
          .set("title", title)
          .set("body", body_)
          .set("summary", summary)
          .set("authorId", authorId.value)
          .set("authorName", authorName)
          .set("status", status.to!string())
          .set("category", category)
          .set("tags", tags.array)
          .set("relatedArticleIds", relatedArticleIds.array)
          .set("language", language)
          .set("viewCount", viewCount)
          .set("helpfulCount", helpfulCount)
          .set("version", version_)
          .set("publishedAt", publishedAt);
  }
}
