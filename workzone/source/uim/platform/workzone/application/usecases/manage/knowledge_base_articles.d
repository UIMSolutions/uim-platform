/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.knowledge_base_articles;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.knowledge_base_article;
import uim.platform.workzone.domain.ports.repositories.knowledge_base_articles;
import uim.platform.workzone.application.dto;

class ManageKnowledgeBaseArticlesUseCase : UIMUseCase {
  private KnowledgeBaseArticleRepository repo;

  this(KnowledgeBaseArticleRepository repo) {
    this.repo = repo;
  }

  CommandResult createArticle(CreateKBArticleRequest req) {
    if (req.title.length == 0)
      return CommandResult("", "Article title is required");

    auto now = Clock.currStdTime();
    auto a = KnowledgeBaseArticle();
    a.id = randomUUID().toString();
    a.workspaceId = req.workspaceId;
    a.tenantId = req.tenantId;
    a.title = req.title;
    a.body_ = req.body_;
    a.summary = req.summary;
    a.authorId = req.authorId;
    a.authorName = req.authorName;
    a.status = KBArticleStatus.draft;
    a.category = req.category;
    a.tags = req.tags;
    a.language = req.language;
    a.version_ = 1;
    a.createdAt = now;
    a.updatedAt = now;

    repo.save(a);
    return CommandResult(a.id, "");
  }

  KnowledgeBaseArticle* getArticle(KBArticleId id, TenantId tenantId) {
    return repo.findById(id, tenantId);
  }

  KnowledgeBaseArticle[] listByWorkspace(WorkspaceId workspaceId, TenantId tenantId) {
    return repo.findByWorkspace(workspaceId, tenantId);
  }

  KnowledgeBaseArticle[] listByCategory(string category, TenantId tenantId) {
    return repo.findByCategory(category, tenantId);
  }

  CommandResult updateArticle(UpdateKBArticleRequest req) {
    auto a = repo.findById(req.id, req.tenantId);
    if (a is null)
      return CommandResult("", "Article not found");

    if (req.title.length > 0)
      a.title = req.title;
    if (req.body_.length > 0)
      a.body_ = req.body_;
    if (req.summary.length > 0)
      a.summary = req.summary;
    a.status = req.status;
    a.category = req.category;
    a.tags = req.tags;
    a.version_ = a.version_ + 1;
    a.updatedAt = Clock.currStdTime();

    repo.update(*a);
    return CommandResult(a.id, "");
  }

  CommandResult deleteArticle(KBArticleId id, TenantId tenantId) {
    auto a = repo.findById(id, tenantId);
    if (a is null)
      return CommandResult("", "Article not found");

    repo.remove(id, tenantId);
    return CommandResult(id, "");
  }
}
