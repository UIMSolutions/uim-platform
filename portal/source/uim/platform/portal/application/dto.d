/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.application.dto;

// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.entities.site : SiteSettings;
// import uim.platform.portal.domain.entities.tile : TileConfiguration;
// import uim.platform.portal.domain.entities.theme : ThemeColors, ThemeFonts;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
/// --- Site DTOs ---

struct CreateSiteRequest {
  TenantId tenantId;
  string name;
  string description;
  string alias_;
  ThemeId themeId;
  SiteSettings settings;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId)
      .set("name", name)
      .set("description", description)
      .set("alias_", alias_)
      .set("themeId", themeId)
      .set("settings", settings.toJson());
  }
}

struct UpdateSiteRequest {
  SiteId siteId;
  string name;
  string description;
  string alias_;
  ThemeId themeId;
  SiteSettings settings;

  Json toJson() const {
    return Json.emptyObject
      .set("siteId", siteId)
      .set("name", name)
      .set("description", description)
      .set("alias_", alias_)
      .set("themeId", themeId)
      .set("settings", settings.toJson());

  }
}

struct SiteResponse {
  string siteId;
  string error;

  bool isSuccess() const {
    return error.length == 0;
  }

  Json toJson() const {
    return Json.emptyObject
      .set("siteId", siteId)
      .set("error", error)
      .set("isSuccess", isSuccess());
  }
}

/// --- Page DTOs ---

struct CreatePageRequest {
  SiteId siteId;
  TenantId tenantId;
  string title;
  string description;
  string alias_;
  PageLayout layout;
  string[] allowedRoleIds;
  int sortOrder;
  bool visible;

  Json toJson() const {
    return Json.emptyObject
      .set("siteId", siteId)
      .set("tenantId", tenantId)
      .set("title", title)
      .set("description", description)
      .set("alias_", alias_)
      .set("layout", layout.to!string())
      .set("allowedRoleIds", allowedRoleIds)
      .set("sortOrder", sortOrder)
      .set("visible", visible);
  }
}

struct UpdatePageRequest {
  PageId pageId;
  string title;
  string description;
  string alias_;
  PageLayout layout;
  string[] allowedRoleIds;
  int sortOrder;
  bool visible;

  Json toJson() const {
    return Json.emptyObject
      .set("pageId", pageId)
      .set("title", title)
      .set("description", description)
      .set("alias_", alias_)
      .set("layout", layout.to!string())
      .set("allowedRoleIds", allowedRoleIds)
      .set("sortOrder", sortOrder)
      .set("visible", visible);
  }

}

struct PageResponse {
  string pageId;
  string error;

  bool isSuccess() const {
    return error.length == 0;
  }

  Json toJson() const {
    return Json.emptyObject
      .set("pageId", pageId)
      .set("error", error)
      .set("isSuccess", isSuccess());
  }
}

/// --- Section DTOs ---

struct CreateSectionRequest {
  PageId pageId;
  TenantId tenantId;
  string title;
  int sortOrder;
  bool visible;
  int columns;

    Json toJson() const {
    return Json.emptyObject
      .set("pageId", pageId)
      .set("tenantId", tenantId)
      .set("title", title)
      .set("sortOrder", sortOrder)
      .set("visible", visible)
      .set("columns", columns);
    }
}

struct UpdateSectionRequest {
  SectionId sectionId;
  string title;
  int sortOrder;
  bool visible;
  int columns;

    Json toJson() const {
    return Json.emptyObject
      .set("sectionId", sectionId)
      .set("title", title)
      .set("sortOrder", sortOrder)
      .set("visible", visible)
      .set("columns", columns);
    }
}

struct SectionResponse {
  SectionId sectionId;
  string error;

  bool isSuccess() const {
    return error.length == 0;
  }

    Json toJson() const {
    return Json.emptyObject      .set("sectionId", sectionId)
      .set("error", error)
      .set("isSuccess", isSuccess());
    }
}

/// --- Tile DTOs ---

struct CreateTileRequest {
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

    Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId)
      .set("catalogId", catalogId)
      .set("title", title)
      .set("subtitle", subtitle)
      .set("description", description)
      .set("icon", icon)
      .set("info", info)
      .set("tileType", tileType.to!string())
      .set("appType", appType.to!string())
      .set("url", url)
      .set("appId", appId)
      .set("navigationTarget", navigationTarget.to!string())
      .set("keywords", keywords)
      .set("allowedRoleIds", allowedRoleIds)
      // Assuming TileConfiguration has a toJson method
      .set("configuration", configuration.toJson());
    }
}

struct UpdateTileRequest {
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

    Json toJson() const {
    return Json.emptyObject
      .set("tileId", tileId)
      .set("title", title)
      .set("subtitle", subtitle)
      .set("description", description)
      .set("icon", icon)
      .set("info", info)
      .set("tileType", tileType.to!string())
      .set("appType", appType.to!string())
      .set("url", url)
      .set("appId", appId)
      .set("navigationTarget", navigationTarget.to!string())
      .set("keywords", keywords)
      .set("allowedRoleIds", allowedRoleIds)
      // Assuming TileConfiguration has a toJson method
      .set("configuration", configuration.toJson());
    }
}

struct TileResponse {
  string tileId;
  string error;

  bool isSuccess() const {
    return error.length == 0;
  }

    Json toJson() const {
    return Json.emptyObject
      .set("tileId", tileId)
      .set("error", error)
      .set("isSuccess", isSuccess());
    }

}

/// --- Catalog DTOs ---

struct CreateCatalogRequest {
  TenantId tenantId;
  string title;
  string description;
  ProviderId providerId;
  string[] allowedRoleIds;
  bool active;

    Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId)
      .set("title", title)
      .set("description", description)
      .set("providerId", providerId)
      .set("allowedRoleIds", allowedRoleIds)
      .set("active", active);
    }
}

struct UpdateCatalogRequest {
  CatalogId catalogId;
  string title;
  string description;
  string[] allowedRoleIds;
  bool active;

    Json toJson() const {
    return Json.emptyObject
      .set("catalogId", catalogId)
      .set("title", title)
      .set("description", description)
      .set("allowedRoleIds", allowedRoleIds)
      .set("active", active);
    }
}

struct CatalogResponse {
  CatalogId catalogId;
  string error;

  bool isSuccess() const {
    return error.length == 0;
  }

    Json toJson() const {
    return Json.emptyObject
      .set("catalogId", catalogId)
      .set("error", error)
      .set("isSuccess", isSuccess());
    }
}

/// --- Content Provider DTOs ---

struct CreateProviderRequest {
  TenantId tenantId;
  string name;
  string description;
  ProviderType providerType;
  string contentEndpointUrl;
  string authToken;
}

struct UpdateProviderRequest {
  ProviderId providerId;
  string name;
  string description;
  string contentEndpointUrl;
  string authToken;
  bool active;

    Json toJson() const {
    return Json.emptyObject
      .set("providerId", providerId)
      .set("name", name)
      .set("description", description)
      .set("contentEndpointUrl", contentEndpointUrl)
      .set("authToken", authToken)
      .set("active", active);
    }
}

struct ProviderResponse {
  ProviderId providerId;
  string error;

  bool isSuccess() const {
    return error.length == 0;
  }

    Json toJson() const {
    return Json.emptyObject
      .set("providerId", providerId)
      .set("error", error)
      .set("isSuccess", isSuccess());
    }
}

/// --- Role DTOs ---

struct CreateRoleRequest {
  TenantId tenantId;
  string name;
  string description;
  RoleScope scope_;

    Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId)
      .set("name", name)
      .set("description", description)
      .set("scope_", scope_.to!string());
    }
}

struct UpdateRoleRequest {
  RoleId roleId;
  string name;
  string description;

    Json toJson() const {
    return Json.emptyObject

      .set("roleId", roleId)
      .set("name", name)
      .set("description", description);
    }
}

struct AssignRoleRequest {
  RoleId roleId;
  string[] userIds;
  string[] groupIds;

    Json toJson() const {
    return Json.emptyObject
      .set("roleId", roleId)
      .set("userIds", userIds)
      .set("groupIds", groupIds);
    }
}

struct RoleResponse {
  RoleId roleId;
  string error;

  bool isSuccess() const {
    return error.length == 0;
  }

    Json toJson() const {
    return Json.emptyObject
      .set("roleId", roleId)
      .set("error", error)
      .set("isSuccess", isSuccess());
    }
}

/// --- Theme DTOs ---

struct CreateThemeRequest {
  TenantId tenantId;
  string name;
  string description;
  ThemeMode mode;
  string baseTheme;
  ThemeColors colors;
  ThemeFonts fonts;
  string customCss;
  bool isDefault;

    Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId)
      .set("name", name)
      .set("description", description)
      .set("mode", mode.to!string())
      .set("baseTheme", baseTheme)
      .set("colors", colors.toJson())
      .set("fonts", fonts.toJson())
      .set("customCss", customCss)
      .set("isDefault", isDefault);
    }
}

struct UpdateThemeRequest {
  ThemeId themeId;
  string name;
  string description;
  ThemeMode mode;
  ThemeColors colors;
  ThemeFonts fonts;
  string customCss;
  bool isDefault;

    Json toJson() const {
    return Json.emptyObject
      .set("themeId", themeId)
      .set("name", name)
      .set("description", description)
      .set("mode", mode.to!string())
      .set("colors", colors.toJson())
      .set("fonts", fonts.toJson())
      .set("customCss", customCss)
      .set("isDefault", isDefault);
    }
}

struct ThemeResponse {
  ThemeId themeId;
  string error;

  bool isSuccess() const {
    return error.length == 0;
  }

    Json toJson() const {
    return Json.emptyObject
      .set("themeId", themeId)
      .set("error", error)
      .set("isSuccess", isSuccess());
    }
}

/// --- Menu Item DTOs ---

struct CreateMenuItemRequest {
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

    Json toJson() const {
    return Json.emptyObject
      .set("siteId", siteId)
      .set("tenantId", tenantId)
      .set("title", title)
      .set("icon", icon)
      .set("parentId", parentId)
      .set("targetPageId", targetPageId)
      .set("targetUrl", targetUrl)
      .set("navigationTarget", navigationTarget.to!string())
      .set("allowedRoleIds", allowedRoleIds)
      .set("sortOrder", sortOrder)
      .set("visible", visible);
    }
}

struct UpdateMenuItemRequest {
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

    Json toJson() const {
    return Json.emptyObject
      .set("menuItemId", menuItemId)
      .set("title", title)
      .set("icon", icon)
      .set("parentId", parentId)
      .set("targetPageId", targetPageId)
      .set("targetUrl", targetUrl)
      .set("navigationTarget", navigationTarget.to!string())
      .set("allowedRoleIds", allowedRoleIds)
      .set("sortOrder", sortOrder)
      .set("visible", visible);
    }

}

struct MenuItemResponse {
  MenuItemId menuItemId;
  string error;

  bool isSuccess() const {
    return error.length == 0;
  }

    Json toJson() const {
    return Json.emptyObject     .set("menuItemId", menuItemId)
      .set("error", error)
      .set("isSuccess", isSuccess());
    }
}

/// --- Translation DTOs ---

struct CreateTranslationRequest {
  TenantId tenantId;
  string resourceType;
  string resourceId;
  string fieldName;
  string language;
  string value;

    Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId)
      .set("resourceType", resourceType)
      .set("resourceId", resourceId)
      .set("fieldName", fieldName)
      .set("language", language)
      .set("value", value);
    }
}

struct UpdateTranslationRequest {
  TranslationId translationId;
  string value;

    Json toJson() const {
    return Json.emptyObject
      .set("translationId", translationId)
      .set("value", value);
    }
}

struct TranslationResponse {
  TranslationId translationId;
  string error;

  bool isSuccess() const {
    return error.length == 0;
  }

    Json toJson() const {
    return Json.emptyObject
      .set("translationId", translationId)
      .set("error", error)
      .set("isSuccess", isSuccess());
    }

}

/// --- Paged list ---

struct PagedListResponse {
  ulong totalResults;
  uint startIndex;
  uint itemsPerPage;

    Json toJson() const {
    return Json.emptyObject
      .set("totalResults", totalResults)
      .set("startIndex", startIndex)
      .set("itemsPerPage", itemsPerPage);
    }
}
