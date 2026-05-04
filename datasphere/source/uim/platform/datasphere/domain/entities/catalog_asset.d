/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.entities.catalog_asset;

// import uim.platform.datasphere.domain.types;
import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
struct CatalogTag {
  string key;
  string value;

  Json toJson() const {
    return Json([
      "key": key,
      "value": value
    ]);
  }
}

struct CatalogAsset {
  mixin TenantEntity!CatalogAssetId;

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
  
  Json toJson() const {
    return entityToJson
      .set("spaceId", spaceId)
      .set("name", name)
      .set("description", description)
      .set("businessName", businessName)
      .set("assetType", assetType.to!string)
      .set("qualityStatus", qualityStatus.to!string)
      .set("sourceObjectId", sourceObjectId)
      .set("tags", tags.map!(t => t.toJson()).array)
      .set("glossaryTerms", glossaryTerms)
      .set("owner", owner)
      .set("accessCount", accessCount);
  }
}
