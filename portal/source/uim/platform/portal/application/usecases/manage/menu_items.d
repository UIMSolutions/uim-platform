/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.application.usecases.manage.menu_items;

// import uim.platform.portal.domain.entities.menu_item;
// import uim.platform.portal.domain.entities.site;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.domain.ports.repositories.menu_items;
// import uim.platform.portal.domain.ports.repositories.sites;
// import uim.platform.portal.application.dto;

// import std.uuid;
// import std.datetime.systime : Clock;
// import std.algorithm : filter;
// import std.array : array;
import uim.platform.portal.application.dto;
import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class ManageMenuItemsUseCase : UIMUseCase {
  private MenuItemRepository menuRepo;
  private SiteRepository siteRepo;

  this(MenuItemRepository menuRepo, SiteRepository siteRepo) {
    this.menuRepo = menuRepo;
    this.siteRepo = siteRepo;
  }

  MenuItemResponse createMenuItem(CreateMenuItemRequest req) {
    if (req.title.length == 0)
      return MenuItemResponse(MenuItemId(""), "Menu item title is required");

    if (!siteRepo.existsById(req.siteId))
      return MenuItemResponse(MenuItemId(""), "Site not found");

    MenuItem item;
    with (item) {
      menuItemId = randomUUID();
      siteId = req.siteId;
      tenantId = req.tenantId;
      title = req.title;
      icon = req.icon;
      parentId = req.parentId;
      targetPageId = req.targetPageId;
      targetUrl = req.targetUrl;
      navigationTarget = req.navigationTarget;
      allowedRoleIds = req.allowedRoleIds.map!(r => RoleId(r)).array;
      sortOrder = req.sortOrder;
      visible = req.visible;
      createdAt = Clock.currStdTime();
      updatedAt = createdAt;
    }
    menuRepo.save(item);

    if (siteRepo.existsById(req.siteId)) {
      auto site = siteRepo.findById(req.siteId);
      site.menuItemIds ~= item.menuItemId;
      site.updatedAt = Clock.currStdTime();
      siteRepo.update(site);
    }

    return MenuItemResponse(item.menuItemId, "");
  }

  MenuItem getMenuItem(MenuItemId id) {
    return menuRepo.findById(id);
  }

  MenuItem[] listMenuItems(SiteId siteId) {
    return menuRepo.findBySite(siteId);
  }

  MenuItem[] getChildren(MenuItemId parentId) {
    return menuRepo.findChildren(parentId);
  }

  string updateMenuItem(UpdateMenuItemRequest req) {
    if (!menuRepo.existsById(req.menuItemId))
      return "Menu item not found";

    auto item = menuRepo.findById(req.menuItemId);
    with (item) {
      title = req.title.length > 0 ? req.title : item.title;
      icon = req.icon;
      parentId = req.parentId;
      targetPageId = req.targetPageId;
      targetUrl = req.targetUrl;
      navigationTarget = req.navigationTarget;
      allowedRoleIds = req.allowedRoleIds.map!(r => RoleId(r)).array;
      sortOrder = req.sortOrder;
      visible = req.visible;
      updatedAt = Clock.currStdTime();
    }
    menuRepo.update(item);
    return "";
  }

  string deleteMenuItem(MenuItemId menuItemId, SiteId siteId) {
    if (!menuRepo.existsById(menuItemId))
      return "Menu item not found";

    menuRepo.remove(menuItemId);

    if (siteRepo.existsById(siteId)) {
      auto site = siteRepo.findById(siteId);
      site.menuItemIds = site.menuItemIds.filter!(m => m != menuItemId).array;
      site.updatedAt = Clock.currStdTime();
      siteRepo.update(site);
    }

    return "";
  }
}
