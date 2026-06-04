/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.presentation.http.controllers.space;
// import uim.platform.datasphere.application.usecases.manage.spaces;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

class SpaceController : ManageHttpController {
  private ManageSpacesUseCase usecase;

  this(ManageSpacesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.get("/api/v1/datasphere/spaces", &handleList);
    router.get("/api/v1/datasphere/spaces/*", &handleGet);
    router.post("/api/v1/datasphere/spaces", &handleCreate);
    router.put("/api/v1/datasphere/spaces/*", &handleUpdate);
    router.delete_("/api/v1/datasphere/spaces/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    
    CreateSpaceRequest r;
    r.tenantId = precheck.tenantId;
    r.spaceId = SpaceId(precheck.id);
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.businessName = data.getString("businessName");
    r.priority = data.getInteger("priority", 0);

    auto result = usecase.createSpace(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Space created successfully", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto spaces = usecase.listSpaces(tenantId);

    auto list = Json.emptyArray;
    foreach (s; spaces) {
      list ~= Json.emptyObject
        .set("id", s.id)
        .set("name", s.name)
        .set("description", s.description)
        .set("businessName", s.businessName)
        .set("priority", s.priority)
        .set("createdAt", s.createdAt)
        .set("updatedAt", s.updatedAt);
    }

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Spaces retrieved successfully", 0, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = SpaceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid space ID", 400);

    auto s = usecase.getSpace(tenantId, id);
    if (s.isNull)
      return errorResponse("Space not found", 404);

    auto resp = Json.emptyObject
      .set("id", s.id)
      .set("name", s.name)
      .set("description", s.description)
      .set("businessName", s.businessName)
      .set("priority", s.priority)
      .set("enableAuditLog", s.enableAuditLog)
      .set("createdAt", s.createdAt)
      .set("updatedAt", s.updatedAt)
      .set("message", "Space retrieved successfully");

    return successResponse("Space retrieved successfully", 200, resp);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    UpdateSpaceRequest r;
    r.tenantId = precheck.tenantId;
    r.spaceId = SpaceId(precheck.id);
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.businessName = data.getString("businessName");
    r.priority = data.getInteger("priority", 0);

    auto result = usecase.updateSpace(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject.set("id", result.id);
    return successResponse("Space updated successfully", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = SpaceId(precheck.id);

    auto result = usecase.deleteSpace(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    res.writeJsonBody(Json.emptyObject, 204);
  }
}
