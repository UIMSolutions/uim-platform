/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.knowledge_base_articles;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.knowledge_base_article;

interface KnowledgeBaseArticleRepository : ITenantRepository!(KnowledgeBaseArticle, KBArticleId) {

  size_t countByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  KnowledgeBaseArticle[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  void removeByWorkspace(TenantId tenantId, WorkspaceId workspaceId);

  size_t countByCategory(TenantId tenantId, string category);
  KnowledgeBaseArticle[] findByCategory(TenantId tenantId, string category);
  void removeByCategory(TenantId tenantId, string category);

}
