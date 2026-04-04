/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.repositories.catalog_assets;

import uim.platform.datasphere.domain.types;
import uim.platform.datasphere.domain.entities.catalog_asset;

interface CatalogAssetRepository {
  CatalogAsset findById(CatalogAssetId id, SpaceId spaceId);
  CatalogAsset[] findBySpace(SpaceId spaceId);
  CatalogAsset[] findByType(AssetType type, SpaceId spaceId);
  CatalogAsset[] search(string query, SpaceId spaceId);
  void save(CatalogAsset ca);
  void update(CatalogAsset ca);
  void remove(CatalogAssetId id, SpaceId spaceId);
  long countBySpace(SpaceId spaceId);
}
