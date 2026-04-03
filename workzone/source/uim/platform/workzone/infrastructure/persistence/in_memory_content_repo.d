module uim.platform.xyz.infrastructure.persistence.memory.content_repo;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.content_item;
import uim.platform.xyz.domain.ports.content_repository;

import std.algorithm : canFind, filter;
import std.array : array;

class MemoryContentRepository : ContentRepository
{
    private ContentItem[ContentId] store;

    ContentItem[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId)
    {
        return store.byValue().filter!(c => c.tenantId == tenantId && c.workspaceId == workspaceId).array;
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
        return store.byValue().filter!(c =>
            c.tenantId == tenantId && c.workspaceId == workspaceId && c.contentType == contentType
        ).array;
    }

    ContentItem[] findByTag(string tag, TenantId tenantId)
    {
        return store.byValue().filter!(c =>
            c.tenantId == tenantId && c.tags.canFind(tag)
        ).array;
    }

    void save(ContentItem item) { store[item.id] = item; }
    void update(ContentItem item) { store[item.id] = item; }
    void remove(ContentId id, TenantId tenantId)
    {
        if (auto p = id in store)
            if (p.tenantId == tenantId)
                store.remove(id);
    }
}
