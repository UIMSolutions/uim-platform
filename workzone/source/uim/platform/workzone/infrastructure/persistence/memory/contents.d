/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.content;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.content_item;
import uim.platform.workzone.domain.ports.repositories.contents;

// import std.algorithm : canFind, filter;
// import std.array : array;

class MemoryContentRepository : TenantRepository!(ContentItem, ContentId), ContentRepository {

  size_t countByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByWorkspace(tenantId, workspaceId).length;
  }

  ContentItem[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByTenant(tenantId).filter!(c => c.workspaceId == workspaceId).array;
  }

  void removeByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return findByWorkspace(tenantId, workspaceId).each!(c => remove(c));
  }

  size_t countByAuthor(TenantId tenantId, UserId authorId) {
    return findByAuthor(tenantId, authorId).length;
  }

  ContentItem[] findByAuthor(TenantId tenantId, UserId authorId) {
    return findByTenant(tenantId).filter!(c => c.authorId == authorId).array;
  }

  void removeByAuthor(TenantId tenantId, UserId authorId) {
    return findByAuthor(tenantId, authorId).each!(c => remove(c));
  }

  size_t countByType(TenantId tenantId, ContentType contentType, WorkspaceId workspaceId) {
    return findByType(tenantId, contentType, workspaceId).length;
  }

  ContentItem[] findByType(TenantId tenantId, ContentType contentType, WorkspaceId workspaceId) {
    return findByTenant(tenantId).filter!(c => c.workspaceId == workspaceId && c.contentType == contentType).array;
  }

  void removeByType(TenantId tenantId, ContentType contentType, WorkspaceId workspaceId) {
    return findByType(tenantId, contentType, workspaceId).each!(c => remove(c));
  }

  size_t countByTag(TenantId tenantId, string tag) {
    return findByTag(tenantId, tag).length;
  }

  ContentItem[] findByTag(TenantId tenantId, string tag) {
    return findByTenant(tenantId).filter!(c => c.tags.canFind(tag)).array;
  }

  void removeByTag(TenantId tenantId, string tag) {
    return findByTag(tenantId, tag).each!(c => remove(c));
  }

}
