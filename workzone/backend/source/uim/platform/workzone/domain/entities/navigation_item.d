/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.entities.navigation_item;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// An entry of the navigation menu of a site (may be nested via parentId).
struct NavigationItem {
  mixin TenantEntity!NavigationItemId;

  SiteId siteId;
  string siteName;
  string title;
  string icon;
  NavigationItemType itemType = NavigationItemType.link;
  string targetUrl;
  AppId targetAppId;
  string targetAppName;
  WorkpageId targetWorkpageId;
  NavigationItemId parentId; /// group entry of the same site
  int sortOrder;
  bool visible = true;
  bool openInNewWindow;
  string[] allowedRoles;
}
