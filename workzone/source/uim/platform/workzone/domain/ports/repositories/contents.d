/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.contents;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.content_item;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
interface ContentRepository : ITenantRepository!(ContentItem, ContentId) {

  size_t countByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  ContentItem[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  void removeByWorkspace(TenantId tenantId, WorkspaceId workspaceId);

  size_t countByAuthor(TenantId tenantId, UserId authorId);
  ContentItem[] findByAuthor(TenantId tenantId, UserId authorId);
  void removeByAuthor(TenantId tenantId, UserId authorId);

  size_t countByType(TenantId tenantId, ContentType contentType, WorkspaceId workspaceId);
  ContentItem[] findByType(TenantId tenantId, ContentType contentType, WorkspaceId workspaceId);
  void removeByType(TenantId tenantId, ContentType contentType, WorkspaceId workspaceId);

  size_t countByStatus(TenantId tenantId, ContentStatus status, WorkspaceId workspaceId);
  ContentItem[] findByTag(TenantId tenantId, string tag);
  void removeByTag(TenantId tenantId, string tag);
  
}
