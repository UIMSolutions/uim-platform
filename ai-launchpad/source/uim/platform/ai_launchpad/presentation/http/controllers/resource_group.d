/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.resource_group;

// import uim.platform.ai_launchpad.application.usecases.manage.resource_groups;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class ResourceGroupController : ManageHttpController {
  private ManageResourceGroupsUseCase usecase;

  this(ManageResourceGroupsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/admin/resource-groups", &handleCreate);
    router.get("/api/v1/admin/resource-groups", &handleList);
    router.get("/api/v1/admin/resource-groups/*", &handleGet);
    router.patch("/api/v1/admin/resource-groups/*", &handlePatch);
    router.delete_("/api/v1/admin/resource-groups/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    auto groups = connectionId.isEmpty
      ? usecase.listResourceGroups(tenantId) : usecase.listResourceGroups(tenantId, connectionId);

    auto list = groups.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Resource groups retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    CreateResourceGroupRequest r;
    r.tenantId = precheck.tenantId;
    r.connectionId = connectionId;
    r.resourceGroupId = data.getString("resourceGroupId");
    r.labels = jsonPairArray(data, "labels");

    auto result = usecase.createResourceGroup(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("id", result.id)
      .set("message", "Resource group created");

    return successResponse("Resource group created successfully", "Created", 201, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ResourceGroupId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid resource group ID", 400);

    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    auto g = usecase.getResourceGroup(tenantId, connectionId, id);
    if (g.isNull)
      return errorResponse("Resource group not found", 404);

    auto responseData = g.toJson();
    return successResponse("Resource group retrieved successfully", 200, responseData);
  }

  protected Json patchHandler(HTTPServerRequest req) {
    auto precheck = super.patchHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ResourceGroupId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid resource group ID", 400);

    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
    if (connectionId.isNull)
      return errorResponse("Invalid connection ID", 400);

    auto data = precheck.data;
    PatchResourceGroupRequest r;
    r.tenantId = precheck.tenantId;
    r.connectionId = connectionId;
    r.resourceGroupId = id;
    r.labels = jsonPairArray(data, "labels");

    auto result = usecase.patchResourceGroup(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Resource group updated successfully", 200, responseData);
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = patchHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ResourceGroupId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid resource group ID", 400);

    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
    if (connectionId.isNull)
      return errorResponse("Invalid connection ID", 400);

    auto result = usecase.deleteResourceGroup(tenantId, connectionId, id);
    if (result.hasError)
      return errorResponse(result.message, 404);

    auto resp = Json.emptyObject.set("id", id);
    return successResponse("Resource group deleted successfully", "Deleted", 200, resp);
  }
}
