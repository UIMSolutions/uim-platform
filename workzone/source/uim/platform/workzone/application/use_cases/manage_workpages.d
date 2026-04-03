module application.usecases.manage_workpages;

import std.uuid;
import std.datetime.systime : Clock;

import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.entities.workpage;
import uim.platform.xyz.domain.ports.workpage_repository;
import uim.platform.xyz.application.dto;

class ManageWorkpagesUseCase
{
    private WorkpageRepository repo;

    this(WorkpageRepository repo)
    {
        this.repo = repo;
    }

    CommandResult createWorkpage(CreateWorkpageRequest req)
    {
        if (req.title.length == 0)
            return CommandResult("", "Page title is required");

        auto now = Clock.currStdTime();
        auto page = Workpage();
        page.id = randomUUID().toString();
        page.workspaceId = req.workspaceId;
        page.tenantId = req.tenantId;
        page.title = req.title;
        page.description = req.description;
        page.sortOrder = req.sortOrder;
        page.isDefault = req.isDefault;
        page.createdAt = now;
        page.updatedAt = now;

        repo.save(page);
        return CommandResult(page.id, "");
    }

    Workpage* getWorkpage(WorkpageId id, TenantId tenantId)
    {
        return repo.findById(id, tenantId);
    }

    Workpage[] listByWorkspace(WorkspaceId workspaceId, TenantId tenantId)
    {
        return repo.findByWorkspace(workspaceId, tenantId);
    }

    CommandResult updateWorkpage(UpdateWorkpageRequest req)
    {
        auto page = repo.findById(req.id, req.tenantId);
        if (page is null)
            return CommandResult("", "Page not found");

        if (req.title.length > 0) page.title = req.title;
        if (req.description.length > 0) page.description = req.description;
        page.sortOrder = req.sortOrder;
        page.visible = req.visible;
        page.updatedAt = Clock.currStdTime();

        repo.update(*page);
        return CommandResult(page.id, "");
    }

    void deleteWorkpage(WorkpageId id, TenantId tenantId)
    {
        repo.remove(id, tenantId);
    }
}
