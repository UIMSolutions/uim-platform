module uim.platform.xyz.domain.entities.site;

import domain.types;

/// Portal site — the top-level container for pages, navigation, and content.
struct Site
{
    SiteId id;
    TenantId tenantId;
    string name;
    string description;
    string alias_; // URL-friendly slug
    SiteStatus status = SiteStatus.draft;
    ThemeId themeId;
    string[] pageIds;
    MenuItemId[] menuItemIds;
    RoleId[] allowedRoleIds;
    SiteSettings settings;
    long createdAt;
    long updatedAt;
    string createdBy;

    bool isPublished() const
    {
        return status == SiteStatus.published;
    }
}

/// Site-level settings.
struct SiteSettings
{
    string logoUrl;
    string faviconUrl;
    string footerText;
    string copyrightText;
    string defaultLanguage;
    string[] supportedLanguages;
    bool showPersonalization;
    bool showNotifications;
    bool showSearch;
    bool showUserActions;
}
