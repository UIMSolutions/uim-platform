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
  mixin TenantEntity!(MenuItemId);

  MenuItemId parentId; // empty = top-level
  string title;
  string icon;
  PageId targetPageId; // internal page link
  string targetUrl; // external URL
  NavigationTarget navigationTarget = NavigationTarget.inPlace;
  RoleId[] allowedRoleIds;
  int sortOrder;
  bool visible = true;
  
  Json toJson() const {
    auto j = entityToJson
      .set("parentId", parentId.value)
      .set("title", title)
      .set("icon", icon)
      .set("targetPageId", targetPageId.value)
      .set("targetUrl", targetUrl)
      .set("navigationTarget", navigationTarget.toString())
      .set("allowedRoleIds", allowedRoleIds.map!(r => r.value).array)
      .set("sortOrder", sortOrder)
      .set("visible", visible);

    return j;
  }
}
