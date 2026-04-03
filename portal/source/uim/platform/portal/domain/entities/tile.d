module uim.platform.portal.domain.entities.tile;

import uim.platform.portal.domain.types;

/// A tile / app launcher within a section.
struct Tile
{
    TileId id;
    TenantId tenantId;
    CatalogId catalogId;
    string title;
    string subtitle;
    string description;
    string icon;          // icon identifier (e.g., "sap-icon://home")
    string info;          // dynamic info text
    TileType tileType = TileType.static_;
    AppType appType = AppType.url;
    string url;           // launch URL
    string appId;         // application component ID
    NavigationTarget navigationTarget = NavigationTarget.inPlace;
    string[] keywords;
    RoleId[] allowedRoleIds;
    TileConfiguration config;
    int sortOrder;
    bool visible = true;
    long createdAt;
    long updatedAt;
}

/// Additional tile configuration.
struct TileConfiguration
{
    string serviceUrl;     // OData service URL for dynamic tiles
    string serviceRefreshInterval; // refresh interval in seconds
    string numberUnit;     // KPI unit
    string targetNumber;   // KPI target
    string indicatorColor; // "Positive", "Critical", "Negative", "Neutral"
    string sizeBehavior;   // "Responsive", "Small"
}
