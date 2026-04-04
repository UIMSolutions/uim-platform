/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.infrastructure.persistence.memory.tiles;

import uim.platform.portal.domain.entities.tile;
import uim.platform.portal.domain.types;
import uim.platform.portal.domain.ports.tile_repository;

// import std.string : toLower, indexOf;

class MemoryTileRepository : TileRepository
{
  private Tile[TileId] store;

  Tile findById(TileId id)
  {
    if (auto p = id in store)
      return *p;
    return Tile.init;
  }

  Tile[] findByCatalog(CatalogId catalogId)
  {
    Tile[] result;
    foreach (t; store.byValue())
    {
      if (t.catalogId == catalogId)
        result ~= t;
    }
    return result;
  }

  Tile[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100)
  {
    Tile[] result;
    uint idx;
    foreach (t; store.byValue())
    {
      if (t.tenantId == tenantId)
      {
        if (idx >= offset && result.length < limit)
          result ~= t;
        idx++;
      }
    }
    return result;
  }

  Tile[] search(TenantId tenantId, string query, uint offset = 0, uint limit = 100)
  {
    Tile[] result;
    auto lowerQuery = query.toLower();
    uint idx;
    foreach (t; store.byValue())
    {
      if (t.tenantId != tenantId)
        continue;

      bool matches = t.title.toLower().indexOf(lowerQuery) >= 0
        || t.description.toLower().indexOf(lowerQuery) >= 0;

      if (!matches)
      {
        foreach (kw; t.keywords)
        {
          if (kw.toLower().indexOf(lowerQuery) >= 0)
          {
            matches = true;
            break;
          }
        }
      }

      if (matches)
      {
        if (idx >= offset && result.length < limit)
          result ~= t;
        idx++;
      }
    }
    return result;
  }

  void save(Tile tile)
  {
    store[tile.id] = tile;
  }

  void update(Tile tile)
  {
    store[tile.id] = tile;
  }

  void remove(TileId id)
  {
    store.remove(id);
  }
}
