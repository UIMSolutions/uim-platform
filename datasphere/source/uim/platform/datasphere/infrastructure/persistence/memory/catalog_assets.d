/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.catalog_assets;

// import uim.platform.datasphere.domain.entities.catalog_asset;
// import uim.platform.datasphere.domain.ports.repositories.catalog_assets;

 


import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:

class MemoryCatalogAssetRepository : TenantRepository!(CatalogAsset, CatalogAssetId), CatalogAssetRepository {

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
  CatalogAsset[] findBySpace(TenantId tenantId, SpaceId spaceId) {
    return filterBySpace(findByTenant(tenantId), spaceId);
  }
  void removeBySpace(TenantId tenantId, SpaceId spaceId) {
    findBySpace(tenantId, spaceId).each!(ca => remove(ca));
  }
  // #endregion BySpace


  CatalogAsset[] findByType(TenantId tenantId, SpaceId spaceId, AssetType type) {
    if (spaceId in store)
      return store[spaceId].filter!(ca => ca.assetType == type).array;
    return null;
  }

  CatalogAsset[] search(TenantId tenantId, SpaceId spaceId, string query) {
    if (spaceId in store) {
      auto q = query.toLower;
      return store[spaceId].filter!(ca =>
        ca.name.toLower.canFind(q) ||
        ca.description.toLower.canFind(q) ||
        ca.businessName.toLower.canFind(q)
      ).array;
    }
    return null;
  }

  void save(TenantId tenantId, CatalogAsset ca) {
    store[ca.spaceId] ~= ca;
  }

  void update(TenantId tenantId, CatalogAsset ca) {
    if (ca.spaceId in store) {
      foreach (existing; store[ca.spaceId]) {
        if (existing.id == ca.id) {
          existing = ca;
          return;
        }
      }
    }
  }

}
