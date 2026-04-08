/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.knowledge_base_article;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.knowledge_base_article;
import uim.platform.workzone.domain.ports.repositories.knowledge_base_articles;

// import std.algorithm : filter;
// import std.array : array;

class MemoryKnowledgeBaseArticleRepository : KnowledgeBaseArticleRepository {
  private KnowledgeBaseArticle[KBArticleId] store;

  KnowledgeBaseArticle[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId) {
    return store.byValue().filter!(a => a.tenantId == tenantId && a.workspaceId == workspaceId).array;
  }

  KnowledgeBaseArticle* findById(KBArticleId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  KnowledgeBaseArticle[] findByCategory(string category, TenantId tenantId) {
    return store.byValue().filter!(a => a.tenantId == tenantId && a.category == category).array;
  }

  KnowledgeBaseArticle[] findByTenant(TenantId tenantId) {
    return store.byValue().filter!(a => a.tenantId == tenantId).array;
  }

  void save(KnowledgeBaseArticle article) {
    store[article.id] = article;
  }

  void update(KnowledgeBaseArticle article) {
    store[article.id] = article;
  }

  void remove(KBArticleId id, TenantId tenantId) {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
