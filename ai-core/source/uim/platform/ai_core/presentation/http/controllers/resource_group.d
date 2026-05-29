/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.resource_group;
// import uim.platform.ai_core.application.usecases.manage.resource_groups;
// import uim.platform.ai_core.application.dto;
// import uim.platform.ai_core;
import uim.platform.ai_core;

mixin(ShowModule!());

@safe:
class ResourceGroupController : ManageController {
  private ManageResourceGroupsUseCase groups;

  this(ManageResourceGroupsUseCase groups) {
    this.groups = groups;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v2/admin/resourceGroups", &handleCreate);
    router.get("/api/v2/admin/resourceGroups", &handleList);
    router.get("/api/v2/admin/resourceGroups/*", &handleGet);
    router.patch("/api/v2/admin/resourceGroups/*", &handlePatch);
    router.delete_("/api/v2/admin/resourceGroups/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto groups = groups.listResourceGroups(tenantId);
    auto jarr = Json.emptyArray;
    foreach (rg; groups) {
      auto lArr = Json.emptyArray;
      foreach (lbl; rg.labels) {
        lArr ~= Json.emptyObject
          .set("key", lbl.key)
          .set("value", lbl.value);
      }

      jarr ~= Json.emptyObject
        .set("resourceGroupId", rg.id)
        .set("tenantId", rg.tenantId)
        .set("status", rg.status)
        .set("createdAt", rg.createdAt)
        .set("labels", lArr);
    }

    auto responseData = Json.emptyObject
      .set("count", items.length)
      .set("resources", list);
    return successResponse("Resource group list retrieved successfully", 200, responseData);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateResourceGroupRequest r;
    r.tenantId = tenantId;
    r.resourceGroupId = ResourceGroupId(data.getString("resourceGroupId"));
    r.status = data.getString("status");
    r.description = data.getString("description");
    r.labels = jsonKeyValuePairs(j, "labels");

    auto result = groups.createResourceGroup(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Resource group created successfully", 201, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = req.getTenantId();
    auto id = ResourceGroupId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid resource group ID", 400);

    auto rg = groups.getResourceGroup(tenantId, id);
    if (rg.isNull)
      return errorResponse("Scan job not found", 404);

    auto responseData = job.toJson();
    return successResponse("Resource group retrieved successfully", 200, responseData);
  }

  override protected Json patchHandler(HTTPServerRequest req) {
    auto precheck = super.patchHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ResourceGroupId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid resource group ID", 400);

    auto data = precheck.data;
    PatchResourceGroupRequest r;
    r.tenantId = tenantId;
    r.resourceGroupId = id;
    r.labels = jsonKeyValuePairs(data, "labels");

    auto result = groups.patchResourceGroup(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto resp = Json.emptyObject
      .set("resourceGroupId", result.id);

    return successResponse("Resource group updated successfully", 200, resp);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = ResourceGroupId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid resource group ID", 400);

    auto result = groups.deleteResourceGroup(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Resource group deleted successfully", 200, responseData);
  }
}
