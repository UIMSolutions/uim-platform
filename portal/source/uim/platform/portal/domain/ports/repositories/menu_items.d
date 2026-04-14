/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.domain.ports.repositories.menu_items;

// import uim.platform.portal.domain.entities.menu_item;
// import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
/// Port: outgoing — menu item persistence.
interface MenuItemRepository {
  bool existsById(MenuItemId id);
  MenuItem findById(MenuItemId id);

  MenuItem[] findBySite(SiteId siteId);
  MenuItem[] findChildren(MenuItemId parentId);

  void save(MenuItem item);
  void update(MenuItem item);
  void remove(MenuItemId id);
}
