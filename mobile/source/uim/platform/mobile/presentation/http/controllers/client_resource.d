/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.presentation.http.controllers.client_resource;
// import uim.platform.mobile.application.usecases.manage.client_resources;
// import uim.platform.mobile.application.dto;
// import uim.platform.mobile;

import uim.platform.mobile;

// mixin(Showmodule!());

@safe:

class ClientResourceController : ManageHttpController {
  private ManageClientResourcesUseCase usecase;

  this(ManageClientResourcesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/resources", &handleCreate);
    router.get("/api/v1/resources", &handleList);
    router.get("/api/v1/resources/*", &handleGet);
    router.put("/api/v1/resources/*", &handleUpdate);
    router.delete_("/api/v1/resources/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateClientResourceRequest r;
    r.tenantId = tenantId;
    r.appId = data.getString("appId");
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.type = data.getString("type");
    r.contentType = data.getString("contentType");
    r.data = data.getString("data");
    // TODO: ? r.createdBy = UserId(data.getString("createdBy"));
    auto result = usecase.createClientResource(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Client resource created successfully", "Created", 201, resp);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto results = usecase.listClientResources(tenantId);
    auto items = Json.emptyArray;
    foreach (item; results) {
      items ~= Json.emptyObject
        .set("id", item.id)
        .set("appId", item.appId)
        .set("name", item.name)
        // TODO: ? .set("type", item.type)
        .set("contentType", item.contentType);
    }
    auto resp = Json.emptyObject
      .set("items", items)
      .set("totalCount", Json(results.length));

    return successResponse("Client resources retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ClientResourceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid client resource ID", 400);

    auto resource = usecase.getClientResource(tenantId, id);
    if (resource.isNull)
      return errorResponse("Client resource not found", 400);

    auto resp = Json.emptyObject
      .set("id", resource.id)
      .set("tenantId", resource.tenantId)
      .set("appId", resource.appId)
      .set("name", resource.name)
      .set("description", resource.description)
      // TODO: .set("type", resource.type)
      .set("contentType", resource.contentType)
      .set("data", resource.data)
      .set("createdBy", resource.createdBy);

    return successResponse("Client resource retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ClientResourceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid client resource ID", 400);

    auto data = precheck.data;
    UpdateClientResourceRequest r;
    r.tenantId = tenantId;
    r.resourceId = id;
    // TODO: ? r.name = data.getString("name");
    r.description = data.getString("description");
    // TODO: ? r.type = data.getString("type");
    r.contentType = data.getString("contentType");
    r.data = data.getString("data");
    r.updatedBy = UserId(data.getString("updatedBy"));
    auto result = usecase.updateClientResource(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto resp = Json.emptyObject.set("id", result.id);

    return successResponse("Client resource updated successfully", "Updated", 200, resp);

  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ClientResourceId(precheck.id);
    auto result = usecase.deleteClientResource(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    return successResponse("Client resource deleted successfully", "Deleted", 200, Json.emptyObject.set("id", result.id));
  }
}
