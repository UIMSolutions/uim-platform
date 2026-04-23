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

class MemoryKnowledgeBaseArticleRepository : TenantRepository!(KnowledgeBaseArticle, KBArticleId), KnowledgeBaseArticleRepository {
  
  size_t countByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByWorkspace(tenantId, workspaceId).length;
  }

  KnowledgeBaseArticle[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByTenant(tenantId).filter!(a => a.workspaceId == workspaceId).array;
  }

  void removeByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByWorkspace(tenantId, workspaceId).each!(a => remove(a));
  }

  size_t countByCategory(TenantId tenantId, string category) {
    return findByCategory(tenantId, category).length;
  }

  KnowledgeBaseArticle[] findByCategory(TenantId tenantId, string category) {
    return findByTenant(tenantId).filter!(a => a.category == category).array;
  }

  void removeByCategory(TenantId tenantId, string category) {
    return findByCategory(tenantId, category).each!(a => remove(a));
  }

}
