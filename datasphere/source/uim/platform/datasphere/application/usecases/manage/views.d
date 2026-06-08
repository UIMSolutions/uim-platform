/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.application.usecases.manage.views;

// import uim.platform.datasphere.domain.entities.view_;
// import uim.platform.datasphere.domain.ports.repositories.views;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

// mixin(ShowModule!()); 

@safe:
class ManageViewsUseCase { // TODO: UIMUseCase {
  private ViewRepository repo;

  this(ViewRepository repo) {
    this.repo = repo;
  }

  CommandResult createView(CreateViewRequest r) {
    if (r.name.length == 0)
      return CommandResult(false, "", "View name is required");
    if (r.spaceId.isEmpty)
      return CommandResult(false, "", "Space ID is required");

    View v;
    v.initEntity(r.tenantId) ;

    v.id = id;
    v.spaceId = r.spaceId;
    v.name = r.name;
    v.description = r.description;
    v.businessName = r.businessName;
    v.sqlExpression = r.sqlExpression;
    v.isExposed = r.isExposed;

    repo.save(v);
    return CommandResult(true, v.id.value, "");
  }

  View getById(SpaceId spaceId, ViewId id) {
    return repo.findById(spaceId, id);
  }

  View[] list(SpaceId spaceId) {
    return repo.findBySpace(spaceId);
  }

  View[] listExposed(SpaceId spaceId) {
    return repo.findExposed(spaceId);
  }

  CommandResult updateView(UpdateViewRequest r) {
    auto view = repo.findById(r.spaceId, r.viewId);
    if (view.isNull)
      return CommandResult(false, "", "View not found");

    view.name = r.name;
    view.description = r.description;
    view.businessName = r.businessName;
    view.sqlExpression = r.sqlExpression;
    view.isExposed = r.isExposed;
    view.isPersisted = r.isPersisted;

    import core.time : MonoTime;
    view.updatedAt = currentTimestamp;

    repo.update(view);
    return CommandResult(true, view.id.value, "");
  }

  CommandResult deleteView(SpaceId spaceId, ViewId id) {
    auto view = repo.findById(spaceId, id);
    if (view.isNull)
      return CommandResult(false, "", "View not found");

    repo.remove(view);
    return CommandResult(true, view.id.value, "");
  }
}
