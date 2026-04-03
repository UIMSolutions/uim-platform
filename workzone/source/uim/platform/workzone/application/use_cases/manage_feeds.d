module uim.platform.workzone.application.usecases.manage_feeds;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.feed_entry;
import uim.platform.workzone.domain.ports.feed_repository;
import uim.platform.workzone.application.dto;

class ManageFeedsUseCase
{
    private FeedRepository repo;

    this(FeedRepository repo)
    {
        this.repo = repo;
    }

    CommandResult createEntry(CreateFeedEntryRequest req)
    {
        auto entry = FeedEntry();
        entry.id = randomUUID().toString();
        entry.workspaceId = req.workspaceId;
        entry.tenantId = req.tenantId;
        entry.actorId = req.actorId;
        entry.actorName = req.actorName;
        entry.action = req.action;
        entry.objectType = req.objectType;
        entry.objectId = req.objectId;
        entry.objectTitle = req.objectTitle;
        entry.message = req.message;
        entry.createdAt = Clock.currStdTime();

        repo.save(entry);
        return CommandResult(entry.id, "");
    }

    FeedEntry* getEntry(FeedEntryId id, TenantId tenantId)
    {
        return repo.findById(id, tenantId);
    }

    FeedEntry[] listByWorkspace(WorkspaceId workspaceId, TenantId tenantId)
    {
        return repo.findByWorkspace(workspaceId, tenantId);
    }

    void deleteEntry(FeedEntryId id, TenantId tenantId)
    {
        repo.remove(id, tenantId);
    }
}
