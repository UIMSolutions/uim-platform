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

  size_t countByWorkspace(TenantID tenantId, WorkspaceId workspaceId);
  ContentItem[] findByWorkspace(TenantID tenantId, WorkspaceId workspaceId);
  void removeByWorkspace(TenantID tenantId, WorkspaceId workspaceId);

  size_t countByAuthor(TenantID tenantId, UserId authorId);
  ContentItem[] findByAuthor(TenantID tenantId, UserId authorId);
  void removeByAuthor(TenantID tenantId, UserId authorId);

  size_t countByType(TenantID tenantId, ContentType contentType, WorkspaceId workspaceId);
  ContentItem[] findByType(TenantID tenantId, ContentType contentType, WorkspaceId workspaceId);
  void removeByType(TenantID tenantId, ContentType contentType, WorkspaceId workspaceId);

  size_t countByStatus(TenantID tenantId, ContentStatus status, WorkspaceId workspaceId);
  ContentItem[] findByTag(TenantID tenantId, string tag);
  void removeByTag(TenantID tenantId, string tag);
  
}
