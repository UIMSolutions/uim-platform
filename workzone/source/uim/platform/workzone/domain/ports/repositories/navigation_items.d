/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.ports.repositories.navigation_items;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.navigation_item;

interface NavigationItemRepository {
  NavigationItem[] findBySite(SiteId sitetenantId, id tenantId);
  NavigationItem* findById(NavigationItemId tenantId, id tenantId);
  NavigationItem[] findByParent(NavigationItemId parenttenantId, id tenantId);
  NavigationItem[] findByTenant(TenantId tenantId);
  void save(NavigationItem item);
  void update(NavigationItem item);
  void remove(NavigationItemId tenantId, id tenantId);
}
