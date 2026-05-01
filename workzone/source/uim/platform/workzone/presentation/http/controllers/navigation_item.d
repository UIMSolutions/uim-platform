/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.navigation_item;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
import uim.platform.workzone.application.usecases.manage.manage.navigation_items;
import uim.platform.workzone.application.dto;
import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.navigation_item;

class NavigationItemController : PlatformController {
  private ManageNavigationItemsUseCase useCase;

  this(ManageNavigationItemsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/navigation-items", &handleCreate);
    router.get("/api/v1/navigation-items", &handleList);
    router.get("/api/v1/navigation-items/*", &handleGet);
    router.put("/api/v1/navigation-items/*", &handleUpdate);
    router.delete_("/api/v1/navigation-items/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateNavigationItemRequest();
      r.tenantId = req.getTenantId;
      r.siteId = j.getString("siteId");
      r.title = j.getString("title");
      r.icon = j.getString("icon");
      r.targetUrl = j.getString("targetUrl");
      r.targetAppId = j.getString("targetAppId");
      r.targetPageId = j.getString("targetPageId");
      r.parentId = j.getString("parentId");
      r.sortOrder = j.getInteger("sortOrder");
      r.openInNewWindow = j.getBoolean("openInNewWindow");

      auto result = useCase.createNavigationItem(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Navigation item created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto siteId = req.params.get("siteId", "");
      auto items = useCase.listBySite(tenantId, siteId);
      auto arr = Json.emptyArray;
      foreach (n; items)
        arr ~= serializeNavigationItem(n);
      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Navigation items retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto n = useCase.getNavigationItem(tenantId, id);
      if (n.isNull) {
        writeError(res, 404, "Navigation item not found");
        return;
      }
      res.writeJsonBody(serializeNavigationItem(*n), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateNavigationItemRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.title = j.getString("title");
      r.icon = j.getString("icon");
      r.targetUrl = j.getString("targetUrl");
      r.sortOrder = j.getInteger("sortOrder");
      r.visible = j.getBoolean("visible", true);

      auto result = useCase.updateNavigationItem(r);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.deleteNavigationItem(tenantId, id);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.error);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
