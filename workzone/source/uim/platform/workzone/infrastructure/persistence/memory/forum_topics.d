/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.forum_topics;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.forum_topic;
import uim.platform.workzone.domain.ports.repositories.forum_topics;

// import std.algorithm : filter;
// import std.array : array;

class MemoryForumTopicRepository : TenantRepository!(ForumTopic, ForumTopicId), ForumTopicRepository {

  size_t countByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByWorkspace(tenantId, workspaceId).length;
  }

  ForumTopic[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByTenant(tenantId).filter!(t => t.workspaceId == workspaceId).array;
  }

  void removeByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByWorkspace(tenantId, workspaceId).each!(t => remove(t));
  }

  size_t countByAuthor(TenantId tenantId, UserId authorId) {
    return findByAuthor(tenantId, authorId).length;
  }

  ForumTopic[] findByAuthor(TenantId tenantId, UserId authorId) {
    return findByTenant(tenantId).filter!(t => t.authorId == authorId).array;
  }

  void removeByAuthor(TenantId tenantId, UserId authorId) {
    return findByAuthor(tenantId, authorId).each!(t => remove(t));
  }

}
