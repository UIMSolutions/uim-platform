/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.repositories.catalog_assets;
// import uim.platform.datasphere.domain.types;
// import uim.platform.datasphere.domain.entities.catalog_asset;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
interface CatalogAssetRepository : ITenantRepository!(CatalogAsset, CatalogAssetId) {

  bool existsById(TenantId tenantId, SpaceId spaceId, CatalogAssetId id);
  CatalogAsset findById(TenantId tenantId, SpaceId spaceId, CatalogAssetId id);
  void removeById(TenantId tenantId, SpaceId spaceId, CatalogAssetId id);

  size_t countBySpace(TenantId tenantId, SpaceId spaceId);
  CatalogAsset[] findBySpace(TenantId tenantId, SpaceId spaceId);
  void removeBySpace(TenantId tenantId, SpaceId spaceId);

  size_t countByType(TenantId tenantId, SpaceId spaceId, AssetType type);
  CatalogAsset[] findByType(TenantId tenantId, SpaceId spaceId, AssetType type);
  void removeByType(TenantId tenantId, SpaceId spaceId, AssetType type);

  CatalogAsset[] search(TenantId tenantId, SpaceId spaceId, string query);
}
