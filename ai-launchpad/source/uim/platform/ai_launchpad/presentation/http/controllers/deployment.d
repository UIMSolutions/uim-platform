/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.deployment;

// import uim.platform.ai_launchpad.application.usecases.manage.deployments;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

// mixin(ShowModule!());

@safe:

class DeploymentController : ManageHttpController {
  private ManageDeploymentsUseCase usecase;

  this(ManageDeploymentsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/deployments", &handleCreate);
    router.get("/api/v1/deployments", &handleList);
    router.get("/api/v1/deployments/*", &handleGet);
    router.patch("/api/v1/deployments/bulk", &handleBulkPatch);
    router.patch("/api/v1/deployments/*", &handlePatch);
    router.delete_("/api/v1/deployments/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    CreateDeploymentRequest r;
    r.tenantId = tenantId;
    r.connectionId = connectionId;
    r.configurationId = data.getString("configurationId");
    r.resourceGroupId = data.getString("resourceGroupId");
    r.ttl = data.getInteger("ttl");

    auto result = usecase.createDeployment(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Deployment created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
    auto scenarioId = ScenarioId(req.headers.get("X-Scenario-Id", ""));

    auto deployments = scenarioId.isEmpty
      ? usecase.listDeployments(tenantId, connectionId) : usecase.listDeployments(tenantId, connectionId, scenarioId);

    auto list = deployments.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Deployment list retrieved successfully", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = DeploymentId(precheck.id);
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    auto deployment = usecase.getDeployment(tenantId, connectionId, id);
    if (deployment.isNull)
      return errorResponse("Deployment not found", 404);

    auto responseData = deployment.toJson();
    return successResponse("Deployment retrieved successfully", 200, responseData);
  }

  override protected Json patchHandler(HTTPServerRequest req) {
    auto precheck = super.patchHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DeploymentId(precheck.id);
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
    auto data = precheck.data;

    PatchDeploymentRequest r;
    r.tenantId = tenantId;
    r.connectionId = connectionId;
    r.deploymentId = id;
    r.targetStatus = data.getString("targetStatus");
    r.configurationId = data.getString("configurationId");
    r.ttl = data.getInteger("ttl");

    auto result = usecase.patchDeployment(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Deployment updated successfully", 200, responseData);
  }

  protected Json bulkPatchHandler(HTTPServerRequest req) {
    auto precheck = super.patchHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
    auto data = precheck.data;

    BulkPatchDeploymentRequest r;
    r.tenantId = tenantId;
    r.connectionId = connectionId;
    r.deploymentIds = data.getStrings("deploymentIds").map!(id => DeploymentId(id)).array;
    r.targetStatus = data.getString("targetStatus");

    auto results = usecase.bulkPatchDeployments(r);
    auto jarr = Json.emptyArray;
    foreach (result; results) {
      auto rj = Json.emptyObject
        .set("id", result.id)
        .set("success", result.success)
        .set("message", result.success ? "Deployment updated" : "Failed to update deployment");

      if (result.message.length > 0)
        rj = rj.set("error", Json(result.message));
      jarr ~= rj;
    }

    Json resp = Json.emptyObject
      .set("results", jarr);
    return successResponse("Bulk deployment update completed", 200, resp);
  }

  mixin(HandleTemplate!("handleBulkPatch", "bulkPatchHandler"));

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = DeploymentId(precheck.id);
    if (id.isNull)
      return errorResponse("Deployment ID is required", 400);

    auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

    auto result = usecase.deleteDeployment(tenantId, connectionId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Scan job deleted successfully", "Deleted", 200, responseData);
  }
}
