/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.content_repo;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.content_item;
import uim.platform.workzone.domain.ports.content_repository;

// import std.algorithm : canFind, filter;
// import std.array : array;

class MemoryContentRepository : ContentRepository
{
  private ContentItem[ContentId] store;

  ContentItem[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId)
  {
    return store.byValue().filter!(c => c.tenantId == tenantId && c.workspaceId == workspaceId)
      .array;
  }

  ContentItem* findById(ContentId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  ContentItem[] findByAuthor(UserId authorId, TenantId tenantId)
  {
    return store.byValue().filter!(c => c.tenantId == tenantId && c.authorId == authorId).array;
  }

  ContentItem[] findByType(ContentType contentType, WorkspaceId workspaceId, TenantId tenantId)
  {
    return store.byValue().filter!(c => c.tenantId == tenantId
        && c.workspaceId == workspaceId && c.contentType == contentType).array;
  }

  ContentItem[] findByTag(string tag, TenantId tenantId)
  {
    return store.byValue().filter!(c => c.tenantId == tenantId && c.tags.canFind(tag)).array;
  }

  void save(ContentItem item)
  {
    store[item.id] = item;
  }

  void update(ContentItem item)
  {
    store[item.id] = item;
  }

  void remove(ContentId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
