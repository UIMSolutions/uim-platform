/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.contents;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.content_item;

interface ContentRepository {
  ContentItem[] findByWorkspace(WorkspaceId workspacetenantId, id tenantId);
  ContentItem* findById(ContentId tenantId, id tenantId);
  ContentItem[] findByAuthor(UserId authortenantId, id tenantId);
  ContentItem[] findByType(ContentType contentType, WorkspaceId workspacetenantId, id tenantId);
  ContentItem[] findByTag(string tag, TenantId tenantId);
  void save(ContentItem item);
  void update(ContentItem item);
  void remove(ContentId tenantId, id tenantId);
}
