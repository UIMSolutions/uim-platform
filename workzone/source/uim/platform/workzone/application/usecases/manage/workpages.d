/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.workpages;

// import std.uuid;
// import std.datetime.systime : Clock;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.workpage;
// import uim.platform.workzone.domain.ports.repositories.workpages;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ManageWorkpagesUseCase { // TODO: UIMUseCase {
  private WorkpageRepository repo;

  this(WorkpageRepository repo) {
    this.repo = repo;
  }

  CommandResult createWorkpage(CreateWorkpageRequest req) {
    if (req.title.length == 0)
      return CommandResult(false, "", "Page title is required");

    auto now = Clock.currStdTime();
    auto page = Workpage();
    page.id = randomUUID();
    page.workspaceId = req.workspaceId;
    page.tenantId = req.tenantId;
    page.title = req.title;
    page.description = req.description;
    page.sortOrder = req.sortOrder;
    page.isDefault = req.isDefault;
    page.createdAt = now;
    page.updatedAt = now;

    repo.save(page);
    return CommandResult(true, page.id.value, "");
  }

  Workpage getWorkpage(TenantId tenantId, WorkpageId id) {
    return repo.findById(tenantId, id);
  }

  Workpage[] listByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return repo.findByWorkspace(tenantId, workspaceId);
  }

  CommandResult updateWorkpage(UpdateWorkpageRequest req) {
    auto page = repo.findById(req.tenantId, req.id);
    if (page.isNull)
      return CommandResult(false, "", "Page not found");

    if (req.title.length > 0)
      page.title = req.title;
    if (req.description.length > 0)
      page.description = req.description;
    page.sortOrder = req.sortOrder;
    page.visible = req.visible;
    page.updatedAt = Clock.currStdTime();

    repo.update(page);
    return CommandResult(true, page.id.value, "");
  }

  void deleteWorkpage(TenantId tenantId, WorkpageId id) {
    repo.removeById(tenantId, id);
  }
}
