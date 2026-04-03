module uim.platform.xyz.domain.entities.feed_entry;

import domain.types;

/// An activity feed entry — records actions and events in a workspace.
struct FeedEntry
{
    FeedEntryId id;
    WorkspaceId workspaceId;
    TenantId tenantId;
    UserId actorId;
    string actorName;
    string action;           // e.g., "created", "updated", "commented", "joined"
    string objectType;       // e.g., "content", "workspace", "task"
    string objectId;
    string objectTitle;
    string message;
    string[] mentionedUserIds;
    long createdAt;
}
