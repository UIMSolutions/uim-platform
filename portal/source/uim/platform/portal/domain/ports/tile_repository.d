module uim.platform.portal.domain.ports.tile_repository;

import uim.platform.portal.domain.entities.tile;
import uim.platform.portal.domain.types;

/// Port: outgoing — tile / app launcher persistence.
interface TileRepository
{
    Tile findById(TileId id);
    Tile[] findByCatalog(CatalogId catalogId);
    Tile[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
    Tile[] search(TenantId tenantId, string query, uint offset = 0, uint limit = 100);
    void save(Tile tile);
    void update(Tile tile);
    void remove(TileId id);
}
