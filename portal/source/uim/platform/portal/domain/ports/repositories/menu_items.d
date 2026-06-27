/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.ports.repositories.menu_items;
// import uim.platform.portal.domain.entities.menu_item;
// import uim.platform.portal.domain.types;
import uim.platform.portal;

// mixin(ShowModule!());

@safe:
/// Port: outgoing — menu item persistence.
interface MenuItemRepository : ITenantRepository!(MenuItem, MenuItemId) {

  bool existsById(TenantId tenantId, MenuItemId id);
  MenuItem findById(TenantId tenantId, MenuItemId id);
  void removeById(TenantId tenantId, MenuItemId id);

  bool existsByName(TenantId tenantId, SiteId siteId, string name);
  MenuItem findByName(TenantId tenantId, SiteId siteId, string name);
  void removeByName(TenantId tenantId, SiteId siteId, string name);

  size_t countBySite(TenantId tenantId, SiteId siteId);
  MenuItem[] findBySite(TenantId tenantId, SiteId siteId);
  void removeBySite(TenantId tenantId, SiteId siteId);

  size_t countChildren(TenantId tenantId, MenuItemId parentId);
  MenuItem[] findChildren(TenantId tenantId, MenuItemId parentId);
  void removeChildren(TenantId tenantId, MenuItemId parentId);
  
}
