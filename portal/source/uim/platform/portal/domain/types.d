module domain.types;

/// Unique identifier type aliases for type safety.
alias SiteId = string;
alias PageId = string;
alias SectionId = string;
alias TileId = string;
alias CatalogId = string;
alias GroupId = string;
alias RoleId = string;
alias ProviderId = string;
alias ThemeId = string;
alias MenuItemId = string;
alias TenantId = string;
alias TranslationId = string;

/// Site status.
enum SiteStatus
{
    draft,
    published,
    unpublished,
    archived,
}

/// Page layout type.
enum PageLayout
{
    freeform,
    anchored,
    twoColumn,
    threeColumn,
    dashboard,
}

/// Tile type (app launcher type).
enum TileType
{
    static_,     // simple link tile
    dynamic,     // tile with dynamic data count
    custom,      // custom widget tile
    news,        // news/feed tile
    kpi,         // KPI indicator tile
}

/// App type for tiles.
enum AppType
{
    sapui5,
    webDynpro,
    sapGuiHtml,
    url,
    webComponent,
    native_,
}

/// Content provider type.
enum ProviderType
{
    local,
    remote,
    federated,
}

/// Theme mode.
enum ThemeMode
{
    light,
    dark,
    highContrast,
    highContrastDark,
}

/// Navigation target type.
enum NavigationTarget
{
    inPlace,
    newWindow,
    embedded,
}

/// Transport status.
enum TransportStatus
{
    pending,
    inProgress,
    completed,
    failed,
}

/// Role assignment scope.
enum RoleScope
{
    site,
    catalog,
    group,
    page,
}
