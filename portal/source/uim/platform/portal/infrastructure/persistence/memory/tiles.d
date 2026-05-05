/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.infrastructure.persistence.memory.tiles;

// import uim.platform.portal.domain.entities.tile;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.tiles;

// import std.string : toLower, indexOf;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class MemoryTileRepository : TenantRepository!(Tile, TileId), TileRepository {

  size_t countByCatalog(CatalogId catalogId) {
    return findByCatalog(catalogId).length;
  }

  Tile[] findByCatalog(CatalogId catalogId) {
    return findAll().filter!(t => t.catalogId == catalogId).array;
  }

  void removeByCatalog(CatalogId catalogId) {
    findByCatalog(catalogId).each!(t => store.remove(t));
  }

  Tile[] search(TenantId tenantId, string query, size_t offset = 0, size_t limit = 100) {
    Tile[] result;
    auto lowerQuery = query.toLower();
    size_t idx;
    foreach (t; findAll())
      if (t.tenantId != tenantId)
        continue;

    bool matches = t.title.toLower().indexOf(lowerQuery) >= 0
      || t.description.toLower().indexOf(lowerQuery) >= 0;

    if (!matches) {
      foreach (kw; t.keywords) {
        if (kw.toLower().indexOf(lowerQuery) >= 0) {
          matches = true;
          break;
        }
      }
    }

    if (matches) {
      if (idx >= offset && result.length < limit)
        result ~= t;
      idx++;
    }


  return result;
}

