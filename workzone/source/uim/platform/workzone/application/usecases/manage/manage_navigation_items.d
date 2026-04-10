/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.manage.navigation_items;

// import std.uuid;
// import std.datetime.systime : Clock;

import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.navigation_item;
import uim.platform.workzone.domain.ports.repositories.navigation_items;
import uim.platform.workzone.application.dto;

class ManageNavigationItemsUseCase : UIMUseCase {
  private NavigationItemRepository repo;

  this(NavigationItemRepository repo) {
    this.repo = repo;
  }

  CommandResult createNavigationItem(CreateNavigationItemRequest req) {
    if (req.title.length == 0)
      return CommandResult(false, "", "Navigation item title is required");

    auto now = Clock.currStdTime();
    auto n = NavigationItem();
    n.id = randomUUID();
    n.siteId = req.siteId;
    n.tenantId = req.tenantId;
    n.title = req.title;
    n.icon = req.icon;
    n.itemType = req.itemType;
    n.targetUrl = req.targetUrl;
    n.targetAppId = req.targetAppId;
    n.targetPageId = req.targetPageId;
    n.parentId = req.parentId;
    n.sortOrder = req.sortOrder;
    n.visible = true;
    n.openInNewWindow = req.openInNewWindow;
    n.createdAt = now;
    n.updatedAt = now;

    repo.save(n);
    return CommandResult(n.id, "");
  }

  NavigationItem* getNavigationItem(NavigationItemId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  NavigationItem[] listBySite(SiteId sitetenantId, id tenantId) {
    return repo.findBySite(sitetenantId, id);
  }

  CommandResult updateNavigationItem(UpdateNavigationItemRequest req) {
    auto n = repo.findById(req.id, req.tenantId);
    if (n is null)
      return CommandResult(false, "", "Navigation item not found");

    if (req.title.length > 0)
      n.title = req.title;
    if (req.icon.length > 0)
      n.icon = req.icon;
    n.targetUrl = req.targetUrl;
    n.sortOrder = req.sortOrder;
    n.visible = req.visible;
    n.updatedAt = Clock.currStdTime();

    repo.update(*n);
    return CommandResult(n.id, "");
  }

  CommandResult deleteNavigationItem(NavigationItemId tenantId, id tenantId) {
    auto n = repo.findById(tenantId, id);
    if (n is null)
      return CommandResult(false, "", "Navigation item not found");

    repo.remove(tenantId, id);
    return CommandResult(true, id.toString, "");
  }
}
