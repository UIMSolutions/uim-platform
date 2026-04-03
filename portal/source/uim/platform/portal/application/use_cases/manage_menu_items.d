module uim.platform.xyz.application.usecases.manage_menu_items;

import uim.platform.xyz.domain.entities.menu_item;
import uim.platform.xyz.domain.entities.site;
import uim.platform.xyz.domain.types;
import uim.platform.xyz.domain.ports.menu_item_repository;
import uim.platform.xyz.domain.ports.site_repository;
import uim.platform.xyz.application.dto;

import std.uuid;
import std.datetime.systime : Clock;
import std.algorithm : filter;
import std.array : array;

class ManageMenuItemsUseCase
{
    private MenuItemRepository menuRepo;
    private SiteRepository siteRepo;

    this(MenuItemRepository menuRepo, SiteRepository siteRepo)
    {
        this.menuRepo = menuRepo;
        this.siteRepo = siteRepo;
    }

    MenuItemResponse createMenuItem(CreateMenuItemRequest req)
    {
        if (req.title.length == 0)
            return MenuItemResponse("", "Menu item title is required");

        auto site = siteRepo.findById(req.siteId);
        if (site == Site.init)
            return MenuItemResponse("", "Site not found");

        auto now = Clock.currStdTime();
        auto id = randomUUID().toString();
        auto item = MenuItem(
            id,
            req.siteId,
            req.tenantId,
            req.title,
            req.icon,
            req.parentId,
            req.targetPageId,
            req.targetUrl,
            req.navigationTarget,
            req.allowedRoleIds,
            req.sortOrder,
            req.visible,
            now,
            now,
        );
        menuRepo.save(item);

        site.menuItemIds ~= id;
        site.updatedAt = now;
        siteRepo.update(site);

        return MenuItemResponse(id, "");
    }

    MenuItem getMenuItem(MenuItemId id)
    {
        return menuRepo.findById(id);
    }

    MenuItem[] listMenuItems(SiteId siteId)
    {
        return menuRepo.findBySite(siteId);
    }

    MenuItem[] getChildren(MenuItemId parentId)
    {
        return menuRepo.findChildren(parentId);
    }

    string updateMenuItem(UpdateMenuItemRequest req)
    {
        auto item = menuRepo.findById(req.menuItemId);
        if (item == MenuItem.init)
            return "Menu item not found";

        item.title = req.title.length > 0 ? req.title : item.title;
        item.icon = req.icon;
        item.parentId = req.parentId;
        item.targetPageId = req.targetPageId;
        item.targetUrl = req.targetUrl;
        item.navigationTarget = req.navigationTarget;
        item.allowedRoleIds = req.allowedRoleIds;
        item.sortOrder = req.sortOrder;
        item.visible = req.visible;
        item.updatedAt = Clock.currStdTime();
        menuRepo.update(item);
        return "";
    }

    string deleteMenuItem(MenuItemId menuItemId, SiteId siteId)
    {
        auto item = menuRepo.findById(menuItemId);
        if (item == MenuItem.init)
            return "Menu item not found";

        menuRepo.remove(menuItemId);

        auto site = siteRepo.findById(siteId);
        if (site != Site.init)
        {
            site.menuItemIds = site.menuItemIds.filter!(m => m != menuItemId).array;
            site.updatedAt = Clock.currStdTime();
            siteRepo.update(site);
        }

        return "";
    }
}
