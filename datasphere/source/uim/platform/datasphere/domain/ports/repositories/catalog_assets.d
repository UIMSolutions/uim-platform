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
interface CatalogAssetRepository {
  CatalogAsset findById(SpaceId spaceId, CatalogAssetId id);
  CatalogAsset[] findBySpace(SpaceId spaceId);
  CatalogAsset[] findByType(AssetType type, SpaceId spaceId);
  CatalogAsset[] search(SpaceId spaceId, string query);
  void save(CatalogAsset ca);
  void update(CatalogAsset ca);
  void remove(SpaceId spaceId, CatalogAssetId id);
  size_t countBySpace(SpaceId spaceId);
}
