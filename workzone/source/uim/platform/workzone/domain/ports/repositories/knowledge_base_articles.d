/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.knowledge_base_articles;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.knowledge_base_article;

interface KnowledgeBaseArticleRepository {
  KnowledgeBaseArticle[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId);
  KnowledgeBaseArticle* findById(KBArticleId id, TenantId tenantId);
  KnowledgeBaseArticle[] findByCategory(string category, TenantId tenantId);
  KnowledgeBaseArticle[] findByTenant(TenantId tenantId);
  void save(KnowledgeBaseArticle article);
  void update(KnowledgeBaseArticle article);
  void remove(KBArticleId id, TenantId tenantId);
}
