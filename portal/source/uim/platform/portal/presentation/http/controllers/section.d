/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.portal.presentation.http.controllers.section;

// import uim.platform.portal.application.usecases.manage.sections;
// import uim.platform.portal.application.dto;
// import uim.platform.portal.domain.entities.section;
// import uim.platform.portal.domain.types;
import uim.platform.portal;

mixin(ShowModule!());

@safe:
class SectionController : ManageHttpController {
  private ManageSectionsUseCase useCase;

  this(ManageSectionsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/sections", &handleCreate);
    router.get("/api/v1/sections", &handleList);
    router.get("/api/v1/sections/*", &handleGet);
    router.put("/api/v1/sections/*", &handleUpdate);
    router.delete_("/api/v1/sections/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto createReq = CreateSectionRequest;
    createReq.tenantId = tenantId;
    createReq.pageId = data.getString("pageId");
    createReq.title = data.getString("title");
    createReq.sortOrder = data.getInteger("sortOrder");
    createReq.visible = data.getBoolean("visible", true);
    createReq.columns = data.getInteger("columns", 3);

    auto result = useCase.createSection(createReq);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto response = Json.emptyObject;
    response["id"] = Json(result.sectionId);

    return successResponse("Section created successfully", "Created", 201, response);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto pageId = req.headers.get("X-Page-Id", "");
    auto sections = useCase.listSections(tenantId, pageId);
    auto response = Json.emptyObject;
    response["totalResults"] = Json(sections.length);
    response["resources"] = toJsonArray(sections);

    return successResponse("Sections retrieved successfully", "OK", 200, response);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto sectionId = precheck.id;
    auto section = useCase.getSection(sectionId);
    if (section.isNull)
      return errorResponse("PortalSection not found", 404);

    return successResponse("Section retrieved successfully", "OK", 200, toJsonValue(section));
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto sectionId = precheck.id;
    auto data = precheck.data;
    auto updateReq = UpdateSectionRequest;
    updateReq.tenantId = tenantId;
    updateReq.sectionId = sectionId;
    updateReq.title = data.getString("title");
    updateReq.sortOrder = data.getInteger("sortOrder");
    updateReq.visible = data.getBoolean("visible", true);
    updateReq.columns = data.getInteger("columns", 3);

    auto result = useCase.updateSection(updateReq);
    if (result.hasError)
      return errorResponse(result.message, 404);

    return successResponse("Section updated successfully", "OK", 200, Json.emptyObject);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto sectionId = precheck.id;
    auto data = precheck.data;
    auto pageId = data.getString("pageId");
    auto result = useCase.deleteSection(sectionId, pageId);
    if (result.hasError)
      return errorResponse(result.message, 404);
    return successResponse("Section deleted successfully", "No Content", 204, Json.emptyObject);
  }
}
