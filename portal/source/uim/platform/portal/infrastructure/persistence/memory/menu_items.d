/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.infrastructure.persistence.memory.menu_items;

// import uim.platform.portal.domain.entities.menu_item;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.menu_items;

import uim.platform.portal;

mixin(ShowModule!());

@safe:
class MemoryMenuItemRepository : MenuItemRepository {
  private MenuItem[MenuItemId] store;

  MenuItem findById(MenuItemId id) {
    if (auto p = id in store)
      return *p;
    return MenuItem.init;
  }

  MenuItem[] findBySite(SiteId siteId) {
    MenuItem[] result;
    foreach (m; store.byValue()) {
      if (m.siteId == siteId)
        result ~= m;
    }
    return result;
  }

  MenuItem[] findChildren(MenuItemId parentId) {
    MenuItem[] result;
    foreach (m; store.byValue()) {
      if (m.parentId == parentId)
        result ~= m;
    }
    return result;
  }

  void save(MenuItem item) {
    store[item.id] = item;
  }

  void update(MenuItem item) {
    store[item.id] = item;
  }

  void remove(MenuItemId id) {
    store.remove(id);
  }
}
