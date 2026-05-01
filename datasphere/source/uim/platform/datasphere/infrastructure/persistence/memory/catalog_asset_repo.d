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
  private CatalogAsset[][string] store;

  CatalogAsset findById(CatalogAssetId id, SpaceId spaceId) {
    if (auto sp = spaceId in store) {
      foreach (ca; *sp) {
        if (ca.id == id)
          return ca;
      }
    }
    return CatalogAsset.init;
  }

  CatalogAsset[] findBySpace(SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return *sp;
    return [];
  }

  CatalogAsset[] findByType(AssetType type, SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return (*sp).filter!(ca => ca.assetType == type).array;
    return [];
  }

  CatalogAsset[] search(string query, SpaceId spaceId) {
    if (auto sp = spaceId in store) {
      auto q = query.toLower;
      return (*sp).filter!(ca =>
        ca.name.toLower.canFind(q) ||
        ca.description.toLower.canFind(q) ||
        ca.businessName.toLower.canFind(q)
      ).array;
    }
    return [];
  }

  void save(CatalogAsset ca) {
    store[ca.spaceId] ~= ca;
  }

  void update(CatalogAsset ca) {
    if (auto sp = ca.spaceId in store) {
      foreach (existing; *sp) {
        if (existing.id == ca.id) {
          existing = ca;
          return;
        }
      }
    }
  }

  void remove(CatalogAssetId id, SpaceId spaceId) {
    if (auto sp = spaceId in store) {
      *sp = (*sp).filter!(ca => ca.id != id).array;
    }
  }

  size_t countBySpace(SpaceId spaceId) {
    if (auto sp = spaceId in store)
      return (*sp).length;
    return 0;
  }
}
