/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.navigation_item;

import uim.platform.workzone.domain.types;

/// A navigation item / menu entry — defines site navigation structure.
struct NavigationItem {
  NavigationItemId id;
  SiteId siteId;
  TenantId tenantId;
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
  long createdAt;
  long updatedAt;
}
