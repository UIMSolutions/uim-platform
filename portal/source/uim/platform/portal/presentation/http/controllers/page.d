/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.presentation.http.controllers.page;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import uim.platform.portal.application.usecases.manage.pages;
// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.entities.page;
// import uim.platform.portal.domain.types;
// import uim.platform.identity_authentication.presentation.http.json_utils;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class PageController : PlatformController {
  private ManagePagesUseCase useCase;

  this(ManagePagesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/pages", &handleCreate);
    router.get("/api/v1/pages", &handleList);
    router.get("/api/v1/pages/*", &handleGet);
    router.put("/api/v1/pages/*", &handleUpdate);
    router.delete_("/api/v1/pages/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto createReq = CreatePageRequest(j.getString("siteId"),
        req.headers.get("X-Tenant-Id", ""), j.getString("title"),
        j.getString("description"), j.getString("alias"), jsonEnum!PageLayout(j,
          "layout", PageLayout.freeform), getStringArray(j, "allowedRoleIds"),
        j.getInteger("sortOrder"), j.getBoolean("visible", true),);

      auto result = useCase.createPage(createReq);
      if (result.isSuccess()) {
        auto response = Json.emptyObject
          .set("id", result.pageId);

        res.writeJsonBody(response, 201);
      } else {
        writeApiError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto siteId = getString(Json(req.headers.get("X-Site-Id", "")), "");
      // Use query param for site filter
      auto siteIdParam = req.headers.get("X-Site-Id", "");
      auto pages = useCase.listPages(siteIdParam);
      auto response = Json.emptyObject
        .set("totalResults", pages.length)
        .set("resources", pages);

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto pageId = extractIdFromPath(req.requestURI);
      if (useCase.existsPage(pageId)) {
        writeApiError(res, 404, "Page not found");
        return;
      }

      auto page = useCase.getPage(pageId);
      res.writeJsonBody(toJsonValue(page), 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto pageId = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto updateReq = UpdatePageRequest(pageId, j.getString("title"),
        j.getString("description"), j.getString("alias"), jsonEnum!PageLayout(j,
          "layout", PageLayout.freeform), getStringArray(j, "allowedRoleIds"),
        j.getInteger("sortOrder"), j.getBoolean("visible", true),);

      auto error = useCase.updatePage(updateReq);
      if (error.length > 0)
        writeApiError(res, 404, error);
      else
        res.writeJsonBody(Json.emptyObject, 200);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto pageId = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto siteId = j.getString("siteId");
      auto error = useCase.deletePage(pageId, siteId);
      if (error.length > 0)
        writeApiError(res, 404, error);
      else
        res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e) {
      writeApiError(res, 500, "Internal server error");
    }
  }
}
