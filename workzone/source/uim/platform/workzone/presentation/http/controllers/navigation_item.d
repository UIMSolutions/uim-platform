/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.presentation.http.controllers.navigation_item;



// import uim.platform.workzone.application.usecases.manage.manage.navigation_items;
// import uim.platform.workzone.application.dto;
// import uim.platform.workzone.domain.types;
// import uim.platform.workzone.domain.entities.navigation_item;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
class NavigationItemController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CreateNavigationItemRequest();
      r.tenantId = tenantId;
      r.siteId = data.getString("siteId");
      r.title = data.getString("title");
      r.icon = data.getString("icon");
      r.targetUrl = data.getString("targetUrl");
      r.targetAppId = data.getString("targetAppId");
      r.targetPageId = data.getString("targetPageId");
      r.parentId = data.getString("parentId");
      r.sortOrder = data.getInteger("sortOrder");
      r.openInNewWindow = j.getBoolean("openInNewWindow");

      auto result = useCase.createNavigationItem(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Navigation item created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto siteId = req.params.get("siteId", "");
      auto items = useCase.listBySite(tenantId, siteId);
      auto arr = items.map!(n => n.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Navigation items retrieved successfully");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto n = useCase.getNavigationItem(tenantId, id);
      if (n.isNull) {
        writeError(res, 404, "Navigation item not found");
        return;
      }
      res.writeJsonBody(n.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto data = precheck.data;
      auto r = UpdateNavigationItemRequest();
      r.id = id;
      r.tenantId = tenantId;
      r.title = data.getString("title");
      r.icon = data.getString("icon");
      r.targetUrl = data.getString("targetUrl");
      r.sortOrder = data.getInteger("sortOrder");
      r.visible = j.getBoolean("visible", true);

      auto result = useCase.updateNavigationItem(r);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 200);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = useCase.deleteNavigationItem(tenantId, id);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
