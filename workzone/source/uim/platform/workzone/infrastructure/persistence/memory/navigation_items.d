/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.persistence.memory.navigation_items;

// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.navigation_item;
// import uim.platform.workzone.domain.ports.repositories.navigation_items;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
// import std.algorithm : filter;
// import std.array : array;

class MemoryNavigationItemRepository : TenantRepository!(NavigationItem, NavigationItemId), NavigationItemRepository {

  // #region bySite
  size_t countBySite(TenantId tenantId, SiteId siteId) {
    return findBySite(tenantId, siteId).length;
  }

  NavigationItem[] findBySite(TenantId tenantId, SiteId siteId) {
    return findByTenant(tenantId).filter!(n => n.siteId == siteId).array;
  }

  void removeBySite(TenantId tenantId, SiteId siteId) {
    findBySite(tenantId, siteId).each!(n => remove(n));
  }
  // #endregion bySite

  // #region byParent
  size_t countByParent(TenantId tenantId, NavigationItemId parentId) {
    return findByParent(tenantId, parentId).length;
  }

  NavigationItem[] findByParent(TenantId tenantId, NavigationItemId parentId) {
    return findByTenant(tenantId).filter!(n => n.parentId == parentId).array;
  }

  void removeByParent(TenantId tenantId, NavigationItemId parentId) {
    findByParent(tenantId, parentId).each!(n => remove(n));
  }
  // #endregion byParent
}
