/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.data_access_control;

// import uim.platform.datasphere.domain.entities.data_access_control;
// import uim.platform.datasphere.domain.ports.repositories.data_access_controls;

 
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
class MemoryDataAccessControlRepository : TenantRepository!(DataAccessControl, DataAccessControlId), DataAccessControlRepository {
  
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
  DataAccessControl[] findBySpace(TenantId tenantId, SpaceId spaceId) {
    return filterBySpace(findByTenant(tenantId), spaceId);
  }
  void removeBySpace(TenantId tenantId, SpaceId spaceId) {
    findBySpace(tenantId, spaceId).each!(dac => remove(dac));
  }
  // #endregion BySpace
  
  DataAccessControl[] findByView(SpaceId spaceId, ViewId viewId) {
    if (spaceId in store)
      return store[spaceId].filter!(dac => dac.targetViewIds.any!(id => id == viewId)).array;
    return null;
  }

  void save(DataAccessControl dac) {
    store[dac.spaceId] ~= dac;
  }

  void update(DataAccessControl dac) {
    if (dac.spaceId in store) {
      foreach (existing; store[dac.spaceId]) {
        if (existing.id == dac.id) {
          existing = dac;
          return;
        }
      }
    }
  }

  void remove(SpaceId spaceId, DataAccessControlId id) {
    if (spaceId in store) {
      store[spaceId] = store[spaceId].filter!(dac => dac.id != id).array;
    }
  }

  size_t countBySpace(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId].length;
    return 0;
  }
}
