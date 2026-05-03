/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.navigation_item;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// A navigation item / menu entry — defines site navigation structure.
struct NavigationItem {
  mixin TenantEntity!(NavigationItemId);

  SiteId siteId;
  string title;
  string icon;
  NavigationItemType itemType = NavigationItemType.link;
  string targetUrl;
  AppId targetAppId;
  WorkpageId targetPageId;
  NavigationItemId parentId; // for nested menus
  RoleId[] allowedRoleIds;
  int sortOrder;
  bool visible = true;
  bool openInNewWindow;

  Json toJson() const {
    return entityToJson()
      .set("siteId", siteId.value)
      .set("title", title)
      .set("icon", icon)
      .set("itemType", itemType.toString())
      .set("targetUrl", targetUrl)
      .set("targetAppId", targetAppId.value)
      .set("targetPageId", targetPageId.value)
      .set("parentId", parentId.value)
      .set("allowedRoleIds", allowedRoleIds.map!(r => r.value).array)
      .set("sortOrder", sortOrder)
      .set("visible", visible)
      .set("openInNewWindow", openInNewWindow);
  }
}
