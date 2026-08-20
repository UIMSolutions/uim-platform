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

mixin(ShowModule!()); 

@safe:
class ManageViewsUseCase {
  protected IViewRepository repo;

  this(IViewRepository repo) {
    this.repo = repo;
  }

  UsecaseResult createView(CreateViewRequest r) {
    if (r.name.isEmpty)
      return UsecaseResult(false, "", "DataView name is required");
    if (r.spaceId.isEmpty)
      return UsecaseResult(false, "", "Space ID is required");

    auto v = DataView(r.tenantId, r.viewId);
    v.spaceId = r.spaceId;
    v.name = r.name;
    v.description = r.description;
    v.businessName = r.businessName;
    v.sqlExpression = r.sqlExpression;
    v.isExposed = r.isExposed;

    repo.save(v);
    return UsecaseResult(true, v.id.value, "");
  }

  DataView getView(TenantId tenantId, SpaceId spaceId, DataViewId id) {
    return repo.findById(tenantId, spaceId, id);
  }

  DataView[] listViews(TenantId tenantId, SpaceId spaceId) {
    return repo.findBySpace(tenantId, spaceId);
  }

  DataView[] listExposedViews(TenantId tenantId, SpaceId spaceId) {
    return repo.findExposed(tenantId, spaceId);
  }

  UsecaseResult updateView(UpdateViewRequest r) {
    auto view = repo.findById(r.tenantId, r.spaceId, r.viewId);
    if (view.isNull)
      return UsecaseResult(false, "", "DataView not found");

    view.name = r.name;
    view.description = r.description;
    view.businessName = r.businessName;
    view.sqlExpression = r.sqlExpression;
    view.isExposed = r.isExposed;
    view.isPersisted = r.isPersisted;

    
    view.updatedAt = currentTimestamp;

    repo.update(view);
    return UsecaseResult(true, view.id.value, "");
  }

  UsecaseResult deleteView(TenantId tenantId, SpaceId spaceId, DataViewId id) {
    auto view = repo.findById(tenantId, spaceId, id);
    if (view.isNull)
      return UsecaseResult(false, "", "DataView not found");

    repo.remove(view);
    return UsecaseResult(true, view.id.value, "");
  }
}
