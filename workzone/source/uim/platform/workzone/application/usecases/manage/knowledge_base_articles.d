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

class ManageKnowledgeBaseArticlesUseCase { // TODO: UIMUseCase {
  private KnowledgeBaseArticleRepository repo;

  this(KnowledgeBaseArticleRepository repo) {
    this.repo = repo;
  }

  CommandResult createArticle(CreateKBArticleRequest req) {
    if (req.title.length == 0)
      return CommandResult(false, "", "Article title is required");

    auto now = Clock.currStdTime();
    auto a = KnowledgeBaseArticle();
    a.id = randomUUID();
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

  KnowledgeBaseArticle* getArticle(TenantId tenantId, KBArticleId id) {
    return repo.findById(tenantId, id);
  }

  KnowledgeBaseArticle[] listByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return repo.findByWorkspace(tenantId, workspaceId);
  }

  KnowledgeBaseArticle[] listByCategory(TenantId tenantId, string category) {
    return repo.findByCategory(tenantId, category);
  }

  CommandResult updateArticle(UpdateKBArticleRequest req) {
    auto a = repo.findById(req.tenantId, req.id);
    if (a.isNull)
      return CommandResult(false, "", "Article not found");

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

  CommandResult deleteArticle(TenantId tenantId, KBArticleId id) {
    auto a = repo.findById(tenantId, id);
    if (a.isNull)
      return CommandResult(false, "", "Article not found");

    repo.removeById(tenantId, id);
    return CommandResult(true, id.toString, "");
  }
}
