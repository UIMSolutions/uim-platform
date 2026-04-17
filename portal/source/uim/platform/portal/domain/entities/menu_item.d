/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.menu_item;

// import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
/// Navigation menu item within a site.
struct MenuItem {
  TenantId tenantId;
  SiteId siteId;
  MenuItemId parentId; // empty = top-level
  MenuItemId menuItemId;
  string title;
  string icon;
  PageId targetPageId; // internal page link
  string targetUrl; // external URL
  NavigationTarget navigationTarget = NavigationTarget.inPlace;
  RoleId[] allowedRoleIds;
  int sortOrder;
  bool visible = true;
  long createdAt;
  long updatedAt;

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId)
      .set("siteId", siteId)
      .set("parentId", parentId)
      .set("id", id)
      .set("title", title)
      .set("icon", icon)
      .set("targetPageId", targetPageId)
      .set("targetUrl", targetUrl)
      .set("navigationTarget", navigationTarget)
      .set("allowedRoleIds", allowedRoleIds)
      .set("sortOrder", sortOrder)
      .set("visible", visible)
      .set("createdAt", createdAt)
      .set("updatedAt", updatedAt);
  }
}
