/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.navigation_items;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.navigation_item;
import uim.platform.workzone.domain.ports.repositories.navigation_items;

// import std.algorithm : filter;
// import std.array : array;

class MemoryNavigationItemRepository : NavigationItemRepository {
  private NavigationItem[NavigationItemId] store;

  NavigationItem[] findBySite(SiteId siteId, TenantId tenantId)
  {
    return store.byValue().filter!(n => n.tenantId == tenantId && n.siteId == siteId).array;
  }

  NavigationItem* findById(NavigationItemId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  NavigationItem[] findByParent(NavigationItemId parentId, TenantId tenantId)
  {
    return store.byValue().filter!(n => n.tenantId == tenantId && n.parentId == parentId).array;
  }

  NavigationItem[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(n => n.tenantId == tenantId).array;
  }

  void save(NavigationItem item)
  {
    store[item.id] = item;
  }

  void update(NavigationItem item)
  {
    store[item.id] = item;
  }

  void remove(NavigationItemId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
