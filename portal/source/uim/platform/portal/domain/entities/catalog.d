module uim.platform.xyz.domain.entities.catalog;

import domain.types;

/// Content catalog — groups tiles for content administration.
struct Catalog
{
    CatalogId id;
    TenantId tenantId;
    string title;
    string description;
    ProviderId providerId;
    TileId[] tileIds;
    RoleId[] allowedRoleIds;
    bool active = true;
    long createdAt;
    long updatedAt;
}
