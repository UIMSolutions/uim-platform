/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.view;

// import uim.platform.datasphere.domain.entities.view_;
// import uim.platform.datasphere.domain.ports.repositories.views;

import uim.platform.datasphere;

// mixin(ShowModule!()); 

@safe:
class MemoryViewRepository : TenantRepository!(View, ViewId), Repository {

 // #region ById
  bool existsById(TenantId tenantId, SpaceId spaceId, CatalogAssetId id) {
    return findBySpace(tenantId, spaceId).any!(ca => ca.id == id);
  }

  CatalogAsset findById(TenantId tenantId, SpaceId spaceId, CatalogAssetId id) {
    foreach (ca; findBySpace(tenantId, spaceId)) {
      if (ca.id == id)
        return ca;
    }
    return CatalogAsset.init;
  }

  void removeById(TenantId tenantId, SpaceId spaceId, CatalogAssetId id) {
    remove(findById(tenantId, spaceId, id));
  }
  // #endregion ById

  // #region BySpace
  size_t countBySpace(TenantId tenantId, SpaceId spaceId) {
    return findBySpace(tenantId, spaceId).length;
  }
  View[] findBySpace(TenantId tenantId, SpaceId spaceId) {
    return filterBySpace(find(tenantId), spaceId);
  }
  void removeBySpace(TenantId tenantId, SpaceId spaceId) {
    findBySpace(tenantId, spaceId).each!(v => remove(v));
  }
  // #endregion BySpace

  View[] findBySemantic(SpaceId spaceId, ViewSemantic semantic) {
    if (spaceId in store)
      return store[spaceId].filter!(v => v.semantic == semantic).array;
    return null;
  }

  View[] findExposed(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId].filter!(v => v.isExposed).array;
    return null;
  }

}
