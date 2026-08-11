/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.repositories.views;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class ViewRepository : TenantRepository!(View, ViewId), IViewRepository {

 // #region ById
  bool existsById(TenantId tenantId, SpaceId spaceId, ViewId id) {
    return findBySpace(tenantId, spaceId).any!(v => v.id == id);
  }

  View findById(TenantId tenantId, SpaceId spaceId, ViewId id) {
    foreach (v; findBySpace(tenantId, spaceId)) {
      if (v.id == id)
        return v;
    }
    return View.init;
  }

  void removeById(TenantId tenantId, SpaceId spaceId, ViewId id) {
    remove(findById(tenantId, spaceId, id));
  }
  // #endregion ById

  // #region BySpace
  size_t countBySpace(TenantId tenantId, SpaceId spaceId) {
    return findBySpace(tenantId, spaceId).length;
  }
  View[] findBySpace(TenantId tenantId, SpaceId spaceId) {
    return filterBySpace(findByTenant(tenantId), spaceId);
  }
  void removeBySpace(TenantId tenantId, SpaceId spaceId) {
    findBySpace(tenantId, spaceId).each!(v => remove(v));
  }
  // #endregion BySpace

  size_t countBySemantic(TenantId tenantId, SpaceId spaceId, ViewSemantic semantic) {
    return findBySemantic(tenantId, spaceId, semantic).length;
  }

  View[] filterBySemantic(View[] views, ViewSemantic semantic) {
    return views.filter!(v => v.semantic == semantic).array;
  }

  View[] findBySemantic(TenantId tenantId, SpaceId spaceId, ViewSemantic semantic) {
    return filterBySemantic(findBySpace(tenantId, spaceId), semantic);
  }

  void removeBySemantic(TenantId tenantId, SpaceId spaceId, ViewSemantic semantic) {
    findBySemantic(tenantId, spaceId, semantic).each!(v => remove(v));
  }

  size_t countExposed(TenantId tenantId, SpaceId spaceId) {
    return findExposed(tenantId, spaceId).length;
  }

  View[] filterExposed(View[] views) {
    return views.filter!(v => v.isExposed).array;
  }

  View[] findExposed(TenantId tenantId, SpaceId spaceId) {
    return filterExposed(findBySpace(tenantId, spaceId));
  }

  void removeExposed(TenantId tenantId, SpaceId spaceId) {
    findExposed(tenantId, spaceId).each!(v => remove(v));
  }
  
}
