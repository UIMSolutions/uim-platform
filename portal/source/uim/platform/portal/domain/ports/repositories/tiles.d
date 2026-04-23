/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.ports.repositories.tiles;

// import uim.platform.portal.domain.entities.tile;
// import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
/// Port: outgoing — tile / app launcher persistence.
interface TileRepository : TTenantRepository!(Tile, TileId) {

  size_t countByCatalog(CatalogId catalogId);
  Tile[] findByCatalog(CatalogId catalogId, uint offset = 0, uint limit = 100);
  void removeByCatalog(CatalogId catalogId);
  
  Tile[] search(TenantId tenantId, string query, uint offset = 0, uint limit = 100);

}
