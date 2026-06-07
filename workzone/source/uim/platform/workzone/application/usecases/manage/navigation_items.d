/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.application.usecases.manage.navigation_items;


// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.navigation_item;
// import uim.platform.workzone.domain.ports.repositories.navigation_items;
// import uim.platform.workzone.application.dto;
import uim.platform.workzone;

// mixin(ShowModule!());

@safe:
class ManageNavigationItemsUseCase { // TODO: UIMUseCase {
  private NavigationItemRepository repo;

  this(NavigationItemRepository repo) {
    this.repo = repo;
  }

  CommandResult createNavigationItem(CreateNavigationItemRequest req) {
    if (req.title.length == 0)
      return CommandResult(false, "", "Navigation item title is required");

    NavigationItem n;
    n.initEntity(req.tenantId);

    n.siteId = req.siteId;
    n.title = req.title;
    n.icon = req.icon;
    // TODO: n.itemType = req.itemType;
    n.targetUrl = req.targetUrl;
    n.targetAppId = req.targetAppId;
    n.targetPageId = req.targetPageId;
    n.parentId = req.parentId;
    n.sortOrder = req.sortOrder;
    n.visible = true;
    n.openInNewWindow = req.openInNewWindow;

    repo.save(n);
    return CommandResult(true, n.id.value, "");
  }

  NavigationItem getNavigationItem(TenantId tenantId, NavigationItemId id) {
    return repo.findById(tenantId, id);
  }

  NavigationItem[] listNavigationItems(TenantId tenantId, SiteId siteId) {
    return repo.findBySite(tenantId, siteId);
  }

  CommandResult updateNavigationItem(UpdateNavigationItemRequest req) {
    auto n = repo.findById(req.tenantId, req.id);
    if (n.isNull)
      return CommandResult(false, "", "Navigation item not found");

    if (req.title.length > 0)
      n.title = req.title;
    if (req.icon.length > 0)
      n.icon = req.icon;
    n.targetUrl = req.targetUrl;
    n.sortOrder = req.sortOrder;
    n.visible = req.visible;
    n.updatedAt = currentTimestamp();

    repo.update(n);
    return CommandResult(true, n.id.value, "");
  }

  CommandResult deleteNavigationItem(TenantId tenantId, NavigationItemId id) {
    auto n = repo.findById(tenantId, id);
    if (n.isNull)
      return CommandResult(false, "", "Navigation item not found");

    repo.remove(n);
    return CommandResult(true, n.id.value, "");
  }
}
