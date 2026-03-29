module domain.ports.feed_repository;

import domain.types;
import domain.entities.feed_entry;

interface FeedRepository
{
    FeedEntry[] findByWorkspace(WorkspaceId workspaceId, TenantId tenantId);
    FeedEntry* findById(FeedEntryId id, TenantId tenantId);
    FeedEntry[] findByActor(UserId actorId, TenantId tenantId);
    void save(FeedEntry entry);
    void remove(FeedEntryId id, TenantId tenantId);
}
