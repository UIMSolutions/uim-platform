/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.application.usecases.manage.tiles;

// import uim.platform.portal.domain.entities.tile;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.tiles;
// import uim.platform.portal.application.dto;

// import std.uuid;
// import std.datetime.systime : Clock;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class ManageTilesUseCase : UIMUseCase {
  private TileRepository tileRepo;

  this(TileRepository tileRepo) {
    this.tileRepo = tileRepo;
  }

  TileResponse createTile(CreateTileRequest req) {
    if (req.title.length == 0)
      return TileResponse("", "Tile title is required");

    auto now = Clock.currStdTime();
    auto id = randomUUID();
    auto tile = Tile(id, req.tenantId, req.catalogId, req.title, req.subtitle,
        req.description, req.icon, req.info, req.tileType, req.appType,
        req.url, req.appId, req.navigationTarget, req.keywords,
        req.allowedRoleIds, req.configuration, 0, // sortOrder
        true, // visible
        now, now,);
    tileRepo.save(tile);
    return TileResponse(id, "");
  }

  Tile getTile(TileId id) {
    return tileRepo.findById(id);
  }

  Tile[] listTiles(TenantId tenantId, uint offset = 0, uint limit = 100) {
    return tileRepo.findByTenant(tenantId, offset, limit);
  }

  Tile[] listByCatalog(CatalogId catalogId) {
    return tileRepo.findByCatalog(catalogId);
  }

  Tile[] searchTiles(TenantId tenantId, string query, uint offset = 0, uint limit = 100) {
    return tileRepo.search(tenantId, query, offset, limit);
  }

  string updateTile(UpdateTileRequest req) {
    if (!tileRepo.existsById(req.tileId))
      return "Tile not found";

    auto tile = tileRepo.findById(req.tileId);
    tile.title = req.title.length > 0 ? req.title : tile.title;
    tile.subtitle = req.subtitle;
    tile.description = req.description;
    tile.icon = req.icon;
    tile.info = req.info;
    tile.tileType = req.tileType;
    tile.appType = req.appType;
    tile.url = req.url;
    tile.appId = req.appId;
    tile.navigationTarget = req.navigationTarget;
    tile.keywords = req.keywords;
    tile.allowedRoleIds = req.allowedRoleIds;
    tile.config = req.configuration;
    tile.updatedAt = Clock.currStdTime();
    tileRepo.update(tile);
    return "";
  }

  string deleteTile(TileId id) {
    if (!tileRepo.existsById(id))
      return "Tile not found";

    tileRepo.remove(id);
    return "";
  }
}
