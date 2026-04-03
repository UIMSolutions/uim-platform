module uim.platform.xyz.domain.entities.menu_item;

import domain.types;

/// Navigation menu item within a site.
struct MenuItem
{
    MenuItemId id;
    SiteId siteId;
    TenantId tenantId;
    string title;
    string icon;
    MenuItemId parentId;     // empty = top-level
    PageId targetPageId;     // internal page link
    string targetUrl;        // external URL
    NavigationTarget navigationTarget = NavigationTarget.inPlace;
    RoleId[] allowedRoleIds;
    int sortOrder;
    bool visible = true;
    long createdAt;
    long updatedAt;
}
