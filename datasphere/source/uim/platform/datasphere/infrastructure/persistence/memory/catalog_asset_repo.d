/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.memory.catalog_asset;

// import uim.platform.datasphere.domain.types;
// import uim.platform.datasphere.domain.entities.catalog_asset;
// import uim.platform.datasphere.domain.ports.repositories.catalog_assets;

// import std.algorithm : filter, canFind;
// import std.array : array;
// import std.uni : toLower;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:

class MemoryCatalogAssetRepository : CatalogAssetRepository {
  private CatalogAsset[][SpaceId] store;

  CatalogAsset findById(CatalogAssetId id, SpaceId spaceId) {
    if (spaceId in store) {
      foreach (ca; store[spaceId]) {
        if (ca.id == id)
          return ca;
      }
    }
    return CatalogAsset.init;
  }

  CatalogAsset[] findBySpace(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId];
    return null;
  }

  CatalogAsset[] findByType(AssetType type, SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId].filter!(ca => ca.assetType == type).array;
    return null;
  }

  CatalogAsset[] search(string query, SpaceId spaceId) {
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

  void save(CatalogAsset ca) {
    store[ca.spaceId] ~= ca;
  }

  void update(CatalogAsset ca) {
    if (ca.spaceId in store) {
      foreach (existing; store[ca.spaceId]) {
        if (existing.id == ca.id) {
          existing = ca;
          return;
        }
      }
    }
  }

  void remove(CatalogAssetId id, SpaceId spaceId) {
    if (spaceId in store) {
      store[spaceId] = store[spaceId].filter!(ca => ca.id != id).array;
    }
  }

  size_t countBySpace(SpaceId spaceId) {
    if (spaceId in store)
      return store[spaceId].length;
    return 0;
  }
}
