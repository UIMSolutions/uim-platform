module uim.platform.xyz.application.usecases.manage_content;

import std.uuid;
import std.datetime.systime : Clock;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.content_item;
import uim.platform.xyz.domain.ports.content_repository;
import uim.platform.xyz.domain.services.content_search;
import uim.platform.xyz.application.dto;

class ManageContentUseCase
{
    private ContentRepository repo;

    this(ContentRepository repo)
    {
        this.repo = repo;
    }

    CommandResult createContent(CreateContentRequest req)
    {
        if (req.title.length == 0)
            return CommandResult("", "Content title is required");

        auto now = Clock.currStdTime();
        auto item = ContentItem();
        item.id = randomUUID().toString();
        item.workspaceId = req.workspaceId;
        item.tenantId = req.tenantId;
        item.title = req.title;
        item.body_ = req.body_;
        item.summary = req.summary;
        item.contentType = req.contentType;
        item.status = ContentStatus.draft;
        item.authorId = req.authorId;
        item.authorName = req.authorName;
        item.tags = req.tags;
        item.language = req.language;
        item.createdAt = now;
        item.updatedAt = now;

        repo.save(item);
        return CommandResult(item.id, "");
    }

    ContentItem* getContent(ContentId id, TenantId tenantId)
    {
        return repo.findById(id, tenantId);
    }

    ContentItem[] listByWorkspace(WorkspaceId workspaceId, TenantId tenantId)
    {
        return repo.findByWorkspace(workspaceId, tenantId);
    }

    ContentItem[] searchContent(WorkspaceId workspaceId, TenantId tenantId, string query)
    {
        auto items = repo.findByWorkspace(workspaceId, tenantId);
        return ContentSearchService.search(items, query);
    }

    CommandResult updateContent(UpdateContentRequest req)
    {
        auto item = repo.findById(req.id, req.tenantId);
        if (item is null)
            return CommandResult("", "Content not found");

        if (req.title.length > 0) item.title = req.title;
        if (req.body_.length > 0) item.body_ = req.body_;
        if (req.summary.length > 0) item.summary = req.summary;
        item.status = req.status;
        item.tags = req.tags;
        item.pinned = req.pinned;
        item.updatedAt = Clock.currStdTime();

        if (item.status == ContentStatus.published && item.publishedAt == 0)
            item.publishedAt = Clock.currStdTime();

        repo.update(*item);
        return CommandResult(item.id, "");
    }

    CommandResult publishContent(ContentId id, TenantId tenantId)
    {
        auto item = repo.findById(id, tenantId);
        if (item is null)
            return CommandResult("", "Content not found");

        item.status = ContentStatus.published;
        item.publishedAt = Clock.currStdTime();
        item.updatedAt = Clock.currStdTime();
        repo.update(*item);
        return CommandResult(item.id, "");
    }

    void deleteContent(ContentId id, TenantId tenantId)
    {
        repo.remove(id, tenantId);
    }
}
