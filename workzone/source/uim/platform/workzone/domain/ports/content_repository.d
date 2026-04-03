module uim.platform.workzone.domain.ports.content_repository;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.content_item;

interface ContentRepository
{
    ContentItem[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId);
    ContentItem* findById(ContentId id, TenantId tenantId);
    ContentItem[] findByAuthor(UserId authorId, TenantId tenantId);
    ContentItem[] findByType(ContentType contentType, WorkspaceId workspaceId, TenantId tenantId);
    ContentItem[] findByTag(string tag, TenantId tenantId);
    void save(ContentItem item);
    void update(ContentItem item);
    void remove(ContentId id, TenantId tenantId);
}
