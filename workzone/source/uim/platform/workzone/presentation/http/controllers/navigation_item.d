/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.navigation_item;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
import uim.platform.workzone.application.usecases.manage.manage_navigation_items;
import uim.platform.workzone.application.dto;
import uim.platform.workzone.domain.types;
import uim.platform.workzone.domain.entities.navigation_item;
import uim.platform.identity_authentication.presentation.http.json_utils;

class NavigationItemController {
  private ManageNavigationItemsUseCase useCase;

  this(ManageNavigationItemsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
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
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.siteId = j.getString("siteId");
      r.title = j.getString("title");
      r.icon = j.getString("icon");
      r.targetUrl = j.getString("targetUrl");
      r.targetAppId = j.getString("targetAppId");
      r.targetPageId = j.getString("targetPageId");
      r.parentId = j.getString("parentId");
      r.sortOrder = jsonInt(j, "sortOrder");
      r.openInNewWindow = jsonBool(j, "openInNewWindow");

      auto result = useCase.createNavigationItem(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto siteId = req.params.get("siteId", "");
      auto items = useCase.listBySite(siteId, tenantId);
      auto arr = Json.emptyArray;
      foreach (ref n; items)
        arr ~= serializeNavigationItem(n);
      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto n = useCase.getNavigationItem(id, tenantId);
      if (n is null) {
        writeError(res, 404, "Navigation item not found");
        return;
      }
      res.writeJsonBody(serializeNavigationItem(*n), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateNavigationItemRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.title = j.getString("title");
      r.icon = j.getString("icon");
      r.targetUrl = j.getString("targetUrl");
      r.sortOrder = jsonInt(j, "sortOrder");
      r.visible = jsonBool(j, "visible", true);

      auto result = useCase.updateNavigationItem(r);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = useCase.deleteNavigationItem(id, tenantId);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
