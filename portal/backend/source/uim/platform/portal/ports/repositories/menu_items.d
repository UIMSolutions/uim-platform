/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.ports.repositories.menu_items;

import uim.platform.portal;

mixin(ShowModule!());

@safe:

interface IMenuItemRepository : ITenantRepository!(PortalMenuItem, MenuItemId) {
  PortalMenuItem[] findBySite(TenantId tenantId, SiteId siteId);
  PortalMenuItem[] findByTargetPage(TenantId tenantId, PageId pageId);
  PortalMenuItem[] findChildren(TenantId tenantId, MenuItemId parentId);
}
