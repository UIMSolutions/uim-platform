/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.entities.menu_item;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

/// A navigation menu item of a site (hierarchical through parentItemId).
/// Targets either a page of the site or an external URL.
struct PortalMenuItem {
  mixin TenantEntity!MenuItemId;

  SiteId siteId;
  /// Empty = top level.
  MenuItemId parentItemId;
  /// Label shown in the menu.
  string name;
  string icon;
  PageId targetPageId;
  string targetUrl;
  NavigationTarget navigationTarget = NavigationTarget.inPlace;
  PortalRoleId[] allowedRoleIds;
  int sortOrder;
  bool visible = true;
}
