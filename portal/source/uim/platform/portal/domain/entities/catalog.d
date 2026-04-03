module uim.platform.portal.domain.entities.catalog;

import uim.platform.portal.domain.types;

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
