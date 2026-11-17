/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.workpages;


// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.workpage;
// import uim.platform.workzone.domain.ports.repositories.workpages;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class ManageWorkpagesUseCase {
  protected IWorkpageRepository repo;

  this(IWorkpageRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createWorkpage(CreateWorkpageRequest req) {
    if (req.title.length == 0)
      return UsecaseResult(false, "", "Page title is required");

    auto page = Workpage(req.tenantId);
    page.workspaceId = req.workspaceId;
    page.title = req.title;
    page.description = req.description;
    page.sortOrder = req.sortOrder;
    page.isDefault = req.isDefault;

    repo.save(page);
    return UsecaseResult(true, page.id.value, "");
  }

  Workpage getWorkpage(TenantId tenantId, WorkpageId id) {
    return repo.findById(tenantId, id);
  }

  Workpage[] listByWorkspace(TenantId tenantId, WorkspaceId workspaceId) {
    return repo.findByWorkspace(tenantId, workspaceId);
  }

  UsecaseResult updateWorkpage(UpdateWorkpageRequest req) {
    auto page = repo.findById(req.tenantId, req.id);
    if (page.isNull)
      return UsecaseResult(false, "", "Page not found");

    if (req.title.length > 0)
      page.title = req.title;
    if (req.description.length > 0)
      page.description = req.description;
    page.sortOrder = req.sortOrder;
    page.visible = req.visible;
    page.updatedAt = currentTimestamp();

    repo.update(page);
    return UsecaseResult(true, page.id.value, "");
  }

  UsecaseResult deleteWorkpage(TenantId tenantId, WorkpageId id) {
    auto entity = repo.findById(tenantId, id);
    if (entity.isNull)
      return UsecaseResult(false, "", "Page not found");

    repo.remove(entity);
    return UsecaseResult(true, entity.id.value, "");
  }
}
