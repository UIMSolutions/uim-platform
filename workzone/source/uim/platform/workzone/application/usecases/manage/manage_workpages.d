/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.workpages;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.workpage;
import uim.platform.workzone.domain.ports.repositories.workpages;
import uim.platform.workzone.application.dto;

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
    return CommandResult(page.id, "");
  }

  Workpage* getWorkpage(WorkpageId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  Workpage[] listByWorkspace(WorkspaceId workspacetenantId, id tenantId) {
    return repo.findByWorkspace(workspacetenantId, id);
  }

  CommandResult updateWorkpage(UpdateWorkpageRequest req) {
    auto page = repo.findById(req.id, req.tenantId);
    if (page.isNull)
      return CommandResult(false, "", "Page not found");

    if (req.title.length > 0)
      page.title = req.title;
    if (req.description.length > 0)
      page.description = req.description;
    page.sortOrder = req.sortOrder;
    page.visible = req.visible;
    page.updatedAt = Clock.currStdTime();

    repo.update(*page);
    return CommandResult(page.id, "");
  }

  void deleteWorkpage(WorkpageId tenantId, id tenantId) {
    repo.removeById(tenantId, id);
  }
}
