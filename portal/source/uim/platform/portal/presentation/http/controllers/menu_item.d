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
class MenuItemController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto createReq = CreateMenuItemRequest(data.getString("siteId"),
        req.headers.get("X-Tenant-Id", ""), data.getString("title"),
        data.getString("icon"), data.getString("parentId"), data.getString("targetPageId"),
        data.getString("targetUrl"), jsonEnum!NavigationTarget(j, "navigationTarget",
          NavigationTarget.inPlace), getStrings(j, "allowedRoleIds"),
        j.getInteger("sortOrder"), j.getBoolean("visible", true),);

      auto result = useCase.createMenuItem(createReq);
      if (result.isSuccess()) {
        auto response = Json.emptyObject
        .set("id", result.menuItemId);

        res.writeJsonBody(response, 201);
      } else {
        writeApiError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto siteId = req.headers.get("X-Site-Id", "");
      auto items = useCase.listMenuItems(siteId);
      auto response = Json.emptyObject
        .set("totalResults", items.length)
        .set("resources", items);

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto menuItemId = precheck.id;
      if (!useCase.existsMenuItem(menuItemId)) {
        writeApiError(res, 404, "Menu item not found");
        return;
      }

      auto item = useCase.getMenuItem(menuItemId);
      res.writeJsonBody(toJsonValue(item), 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto menuItemId = precheck.id;
      auto data = precheck.data;
      auto updateReq = UpdateMenuItemRequest(menuItemId, data.getString("title"),
        data.getString("icon"), data.getString("parentId"), data.getString("targetPageId"),
        data.getString("targetUrl"), jsonEnum!NavigationTarget(j, "navigationTarget",
          NavigationTarget.inPlace), getStrings(j, "allowedRoleIds"),
        j.getInteger("sortOrder"), j.getBoolean("visible", true),);

      auto error = useCase.updateMenuItem(updateReq);
      if (error.length > 0)
        writeApiError(res, 404, error);
      else
        res.writeJsonBody(Json.emptyObject, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto menuItemId = precheck.id;
      auto data = precheck.data;
      auto siteId = data.getString("siteId");
      auto error = useCase.deleteMenuItem(menuItemId, siteId);
      if (error.length > 0)
        writeApiError(res, 404, error);
      else
        res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }
}
