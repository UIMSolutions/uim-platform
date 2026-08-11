/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.repositories.catalog_assets;

// import uim.platform.datasphere.domain.entities.catalog_asset;
// import uim.platform.datasphere.domain.ports.repositories.catalog_assets;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

class CatalogAssetRepository : TenantRepository!(CatalogAsset, CatalogAssetId), ICatalogAssetRepository {

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

  size_t countByType(TenantId tenantId, SpaceId spaceId, AssetType type) {
    return findByType(tenantId, spaceId, type).length;
  }

  CatalogAsset[] filterByType(CatalogAsset[] assets, AssetType type) {
    return assets.filter!(ca => ca.assetType == type).array;
  }

  CatalogAsset[] findByType(TenantId tenantId, SpaceId spaceId, AssetType type) {
    return filterByType(findBySpace(tenantId, spaceId), type);
  }

  void removeByType(TenantId tenantId, SpaceId spaceId, AssetType type) {
    findByType(tenantId, spaceId, type).each!(ca => remove(ca));
  }

  CatalogAsset[] search(TenantId tenantId, SpaceId spaceId, string query) {
    auto q = query.toLower;
    return findBySpace(tenantId, spaceId).filter!(ca =>
        ca.name.toLower.canFind(q) ||
        ca.description.toLower.canFind(q) ||
        ca.businessName.toLower.canFind(q)
    ).array;
  }

}
