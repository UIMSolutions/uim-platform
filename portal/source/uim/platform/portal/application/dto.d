module application.dto;

import domain.types;
import domain.entities.site : SiteSettings;
import domain.entities.tile : TileConfiguration;
import domain.entities.theme : ThemeColors, ThemeFonts;

/// --- Site DTOs ---

struct CreateSiteRequest
{
    TenantId tenantId;
    string name;
    string description;
    string alias_;
    ThemeId themeId;
    SiteSettings settings;
}

struct UpdateSiteRequest
{
    SiteId siteId;
    string name;
    string description;
    string alias_;
    ThemeId themeId;
    SiteSettings settings;
}

struct SiteResponse
{
    string siteId;
    string error;

    bool isSuccess() const { return error.length == 0; }
}

/// --- Page DTOs ---

struct CreatePageRequest
{
    SiteId siteId;
    TenantId tenantId;
    string title;
    string description;
    string alias_;
    PageLayout layout;
    string[] allowedRoleIds;
    int sortOrder;
    bool visible;
}

struct UpdatePageRequest
{
    PageId pageId;
    string title;
    string description;
    string alias_;
    PageLayout layout;
    string[] allowedRoleIds;
    int sortOrder;
    bool visible;
}

struct PageResponse
{
    string pageId;
    string error;

    bool isSuccess() const { return error.length == 0; }
}

/// --- Section DTOs ---

struct CreateSectionRequest
{
    PageId pageId;
    TenantId tenantId;
    string title;
    int sortOrder;
    bool visible;
    int columns;
}

struct UpdateSectionRequest
{
    SectionId sectionId;
    string title;
    int sortOrder;
    bool visible;
    int columns;
}

struct SectionResponse
{
    string sectionId;
    string error;

    bool isSuccess() const { return error.length == 0; }
}

/// --- Tile DTOs ---

struct CreateTileRequest
{
    TenantId tenantId;
    CatalogId catalogId;
    string title;
    string subtitle;
    string description;
    string icon;
    string info;
    TileType tileType;
    AppType appType;
    string url;
    string appId;
    NavigationTarget navigationTarget;
    string[] keywords;
    string[] allowedRoleIds;
    TileConfiguration configuration;
}

struct UpdateTileRequest
{
    TileId tileId;
    string title;
    string subtitle;
    string description;
    string icon;
    string info;
    TileType tileType;
    AppType appType;
    string url;
    string appId;
    NavigationTarget navigationTarget;
    string[] keywords;
    string[] allowedRoleIds;
    TileConfiguration configuration;
}

struct TileResponse
{
    string tileId;
    string error;

    bool isSuccess() const { return error.length == 0; }
}

/// --- Catalog DTOs ---

struct CreateCatalogRequest
{
    TenantId tenantId;
    string title;
    string description;
    ProviderId providerId;
    string[] allowedRoleIds;
    bool active;
}

struct UpdateCatalogRequest
{
    CatalogId catalogId;
    string title;
    string description;
    string[] allowedRoleIds;
    bool active;
}

struct CatalogResponse
{
    string catalogId;
    string error;

    bool isSuccess() const { return error.length == 0; }
}

/// --- Content Provider DTOs ---

struct CreateProviderRequest
{
    TenantId tenantId;
    string name;
    string description;
    ProviderType providerType;
    string contentEndpointUrl;
    string authToken;
}

struct UpdateProviderRequest
{
    ProviderId providerId;
    string name;
    string description;
    string contentEndpointUrl;
    string authToken;
    bool active;
}

struct ProviderResponse
{
    string providerId;
    string error;

    bool isSuccess() const { return error.length == 0; }
}

/// --- Role DTOs ---

struct CreateRoleRequest
{
    TenantId tenantId;
    string name;
    string description;
    RoleScope scope_;
}

struct UpdateRoleRequest
{
    RoleId roleId;
    string name;
    string description;
}

struct AssignRoleRequest
{
    RoleId roleId;
    string[] userIds;
    string[] groupIds;
}

struct RoleResponse
{
    string roleId;
    string error;

    bool isSuccess() const { return error.length == 0; }
}

/// --- Theme DTOs ---

struct CreateThemeRequest
{
    TenantId tenantId;
    string name;
    string description;
    ThemeMode mode;
    string baseTheme;
    ThemeColors colors;
    ThemeFonts fonts;
    string customCss;
    bool isDefault;
}

struct UpdateThemeRequest
{
    ThemeId themeId;
    string name;
    string description;
    ThemeMode mode;
    ThemeColors colors;
    ThemeFonts fonts;
    string customCss;
    bool isDefault;
}

struct ThemeResponse
{
    string themeId;
    string error;

    bool isSuccess() const { return error.length == 0; }
}

/// --- Menu Item DTOs ---

struct CreateMenuItemRequest
{
    SiteId siteId;
    TenantId tenantId;
    string title;
    string icon;
    MenuItemId parentId;
    PageId targetPageId;
    string targetUrl;
    NavigationTarget navigationTarget;
    string[] allowedRoleIds;
    int sortOrder;
    bool visible;
}

struct UpdateMenuItemRequest
{
    MenuItemId menuItemId;
    string title;
    string icon;
    MenuItemId parentId;
    PageId targetPageId;
    string targetUrl;
    NavigationTarget navigationTarget;
    string[] allowedRoleIds;
    int sortOrder;
    bool visible;
}

struct MenuItemResponse
{
    string menuItemId;
    string error;

    bool isSuccess() const { return error.length == 0; }
}

/// --- Translation DTOs ---

struct CreateTranslationRequest
{
    TenantId tenantId;
    string resourceType;
    string resourceId;
    string fieldName;
    string language;
    string value;
}

struct UpdateTranslationRequest
{
    TranslationId translationId;
    string value;
}

struct TranslationResponse
{
    string translationId;
    string error;

    bool isSuccess() const { return error.length == 0; }
}

/// --- Paged list ---

struct PagedListResponse
{
    ulong totalResults;
    uint startIndex;
    uint itemsPerPage;
}
