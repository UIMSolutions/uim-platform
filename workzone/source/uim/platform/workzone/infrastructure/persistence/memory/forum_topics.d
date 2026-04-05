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

class MemoryForumTopicRepository : ForumTopicRepository {
  private ForumTopic[ForumTopicId] store;

  ForumTopic[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId)
  {
    return store.byValue().filter!(t => t.tenantId == tenantId && t.workspaceId == workspaceId).array;
  }

  ForumTopic* findById(ForumTopicId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  ForumTopic[] findByAuthor(UserId authorId, TenantId tenantId)
  {
    return store.byValue().filter!(t => t.tenantId == tenantId && t.authorId == authorId).array;
  }

  ForumTopic[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(t => t.tenantId == tenantId).array;
  }

  void save(ForumTopic topic)
  {
    store[topic.id] = topic;
  }

  void update(ForumTopic topic)
  {
    store[topic.id] = topic;
  }

  void remove(ForumTopicId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
