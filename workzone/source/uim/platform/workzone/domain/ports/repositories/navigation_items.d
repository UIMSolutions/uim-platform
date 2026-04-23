/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.navigation_items;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.navigation_item;

interface NavigationItemRepository : ITenantRepository!(NavigationItem, NavigationItemId) {

  size_t countBySite(TenantId tenantId, SiteId siteId);
  NavigationItem[] findBySite(TenantId tenantId, SiteId siteId);
  void removeBySite(TenantId tenantId, SiteId siteId);

  size_t countByParent(TenantId tenantId, NavigationItemId parentId);
  NavigationItem[] findByParent(TenantId tenantId, NavigationItemId parentId);
  void removeByParent(TenantId tenantId, NavigationItemId parentId);

}
