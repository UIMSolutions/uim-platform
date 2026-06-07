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


// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.types;
import uim.platform.portal;

// mixin(ShowModule!());

@safe:
class ManageTilesUseCase { // TODO: UIMUseCase {
  private TileRepository tileRepo;

  this(TileRepository tileRepo) {
    this.tileRepo = tileRepo;
  }

  TileResponse createTile(CreateTileRequest req) {
    if (req.title.length == 0)
      return TileResponse("", "Tile title is required");

    auto now = currentTimestamp();
    Tile tile;
    tile.initEntity(req.tenantId, req.requestedBy);
    with (tile) {
      catalogId = req.catalogId;
      title = req.title;
      subtitle = req.subtitle;
      description = req.description;
      icon = req.icon;
      info = req.info;
      tileType = req.tileType;
      appType = req.appType;
      url = req.url;
      appId = req.appId;
      navigationTarget = req.navigationTarget;
      keywords = req.keywords;
      allowedRoleIds = req.allowedRoleIds.map!(r => RoleId(r)).array.toJson;
      config = req.configuration;
      sortOrder = 0; // default sort order
      visible = true; // default visibility
    }

    tileRepo.save(tile);
    return TileResponse(tile.tileId, "");
  }

  Tile getTile(TileId id) {
    return tileRepo.findById(tenantId, id);
  }

  Tile[] listTiles(TenantId tenantId, size_t offset = 0, size_t limit = 100) {
    return tileRepo.findByTenant(tenantId, offset, limit);
  }

  Tile[] listByCatalog(CatalogId catalogId) {
    return tileRepo.findByCatalog(catalogId);
  }

  Tile[] searchTiles(TenantId tenantId, string query, size_t offset = 0, size_t limit = 100) {
    return tileRepo.search(tenantId, query, offset, limit);
  }

  CommandResult updateTile(UpdateTileRequest req) {
    if (!tileRepo.existsById(req.tileId))
      return CommandResult(false, "", "Tile not found") ;

    auto tile = tileRepo.findById(req.tileId);
    with (tile) {
      title = req.title.length > 0 ? req.title : tile.title;
      subtitle = req.subtitle;
      description = req.description;
      icon = req.icon;
      info = req.info;
      tileType = req.tileType;
      appType = req.appType;
      url = req.url;
      appId = req.appId;
      navigationTarget = req.navigationTarget;
      keywords = req.keywords;
      allowedRoleIds = req.allowedRoleIds;
      config = req.configuration;
      updatedAt = currentTimestamp();
    }
    tileRepo.update(tile);
    return CommandResult(true, tile.tileId.value, "Tile updated successfully.");
  }

  CommandResult deleteTile(TileId id) {
    auto tile = tileRepo.findById(id);
    if (tile.isNull)
      return CommandResult(false, "", "Tile not found");

    tileRepo.remove(tile);
    return CommandResult(true, id.value, "Tile deleted successfully.");
  }
}
