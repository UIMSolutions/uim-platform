/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.presentation.http.controllers.page;

// import uim.platform.portal.application.usecases.manage.pages;
// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.entities.page;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.types;
// import uim.platform.portal.application.usecases.manage;

import uim.platform.portal;
mixin(ShowModule!());

@safe:
class PageController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto createReq = CreatePageRequest(data.getString("siteId"),
      req.headers.get("X-Tenant-Id", ""), data.getString("title"),
      data.getString("description"), data.getString("alias"), jsonEnum!PageLayout(j,
        "layout", PageLayout.freeform), data.getStrings("allowedRoleIds"),
      data.getInteger("sortOrder"), data.getBoolean("visible", true),);

    auto result = useCase.createPage(createReq);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto response = Json.emptyObject
      .set("id", result.pageId);

    return successResponse("Page created successfully", "Created", 201, response);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto siteId = getString(Json(req.headers.get("X-Site-Id", "")), "");
    // Use query param for site filter
    auto siteIdParam = req.headers.get("X-Site-Id", "");
    auto pages = useCase.listPages(siteIdParam);
    auto response = Json.emptyObject
      .set("totalResults", pages.length)
      .set("resources", pages);

    return successResponse("Page list retrieved successfully", "OK", 200, response);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto pageId = precheck.id;
    auto page = useCase.getPage(pageId);
    if (page.isNull)
      return errorResponse("Page not found", 404);

    return successResponse("Page retrieved successfully", "OK", 200, page.toJson);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto pageId = precheck.id;
    auto data = precheck.data;
    auto updateReq = UpdatePageRequest(pageId, data.getString("title"),
      data.getString("description"), data.getString("alias"), jsonEnum!PageLayout(j,
        "layout", PageLayout.freeform), data.getStrings("allowedRoleIds"),
      data.getInteger("sortOrder"), data.getBoolean("visible", true),);

    auto result = useCase.updatePage(updateReq);
    if (result.hasError)
      return errorResponse(result.message, 404);

    return successResponse("Page updated successfully", "OK", 200, Json.emptyObject);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto pageId = precheck.id;
    auto data = precheck.data;
    auto siteId = data.getString("siteId");
    auto result = useCase.deletePage(pageId, siteId);
    if (result.hasError)
      return errorResponse(result.message, 404);

    return successResponse("Page deleted successfully", "OK", 200, Json.emptyObject);
  }
}
