/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.presentation.http.controllers.menu_item;

// import uim.platform.portal.application.usecases.manage.menu_items;
// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.entities.menu_item;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.application.usecases.manage;

import uim.platform.portal;
mixin(ShowModule!());

@safe:
class MenuItemController : ManageHttpController {
  private ManageMenuItemsUseCase useCase;

  this(ManageMenuItemsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/menu-items", &handleCreate);
    router.get("/api/v1/menu-items", &handleList);
    router.get("/api/v1/menu-items/*", &handleGet);
    router.put("/api/v1/menu-items/*", &handleUpdate);
    router.delete_("/api/v1/menu-items/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto createReq = CreateMenuItemRequest(data.getString("siteId"),
      req.headers.get("X-Tenant-Id", ""), data.getString("title"),
      data.getString("icon"), data.getString("parentId"), data.getString("targetPageId"),
      data.getString("targetUrl"), jsonEnum!NavigationTarget(j, "navigationTarget",
        NavigationTarget.inPlace), data.getStrings("allowedRoleIds"),
      data.getInteger("sortOrder"), data.getBoolean("visible", true),);

    auto result = useCase.createMenuItem(createReq);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto response = Json.emptyObject
      .set("id", result.menuItemId);

    return successResponse("Menu item created successfully", "Created", 201, response);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto siteId = req.headers.get("X-Site-Id", "");
    auto items = useCase.listMenuItems(siteId);
    auto response = Json.emptyObject
      .set("totalResults", items.length)
      .set("resources", items);

    return successResponse("Menu item list retrieved successfully", "OK", 200, response);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto menuItemId = precheck.id;
    if (!useCase.existsMenuItem(menuItemId))
      return errorResponse("Menu item not found", 404);

    auto item = useCase.getMenuItem(menuItemId);
    return successResponse("Menu item retrieved successfully", "OK", 200, toJsonValue(item));
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto menuItemId = precheck.id;
    auto data = precheck.data;
    auto request = UpdateMenuItemRequest();
    request.tenantId = tenantId;
    request.menuItemId = menuItemId;
    request.title = data.getString("title");
    request.icon = data.getString("icon");
    request.parentId = data.getString("parentId");
    request.targetPageId = data.getString("targetPageId");
    request.targetUrl = data.getString("targetUrl");
    request.navigationTarget = jsonEnum!NavigationTarget(j, "navigationTarget", NavigationTarget
        .inPlace);
    request.allowedRoleIds = data.getStrings("allowedRoleIds");
    request.sortOrder = data.getInteger("sortOrder");
    request.visible = data.getBoolean("visible", true);

    auto result = useCase.updateMenuItem(request);
    if (result.hasError)
      return errorResponse(result.message, 404);

    return successResponse("Menu item updated successfully", "OK", 200, Json.emptyObject);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto menuItemId = precheck.id;
    auto data = precheck.data;
    auto siteId = data.getString("siteId");
    auto result = useCase.deleteMenuItem(tenantId, menuItemId, siteId);
    if (result.hasError)
      return errorResponse(result.message, 404);

    return successResponse("Menu item deleted successfully", "OK", 200, Json.emptyObject);
  }
}
