/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.entities.catalog_asset;

import uim.platform.datasphere.domain.types;

struct CatalogTag {
  string key;
  string value;
}

struct CatalogAsset {
  CatalogAssetId id;
  TenantId tenantId;
  SpaceId spaceId;
  string name;
  string description;
  string businessName;
  AssetType assetType;
  QualityStatus qualityStatus;
  string sourceObjectId;
  CatalogTag[] tags;
  string[] glossaryTerms;
  string owner;
  long accessCount;
  long createdAt;
  long updatedAt;
}
