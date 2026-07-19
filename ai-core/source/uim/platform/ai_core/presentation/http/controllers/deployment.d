/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.deployment;
// import uim.platform.ai_core.application.usecases.manage.deployments;

// import uim.platform.ai_core;
import uim.platform.ai_core;
mixin(ShowModule!());

@safe:
class DeploymentController : ManageHttpController {
  private ManageDeploymentsUseCase usercase;

  this(ManageDeploymentsUseCase usercase) {
    this.usercase = usercase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v2/lm/deployments", &handleCreate);
    router.get("/api/v2/lm/deployments", &handleList);
    router.get("/api/v2/lm/deployments/*", &handleGet);
    router.patch("/api/v2/lm/deployments/*", &handlePatch);
    router.delete_("/api/v2/lm/deployments/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateDeploymentRequest r;
    r.tenantId = tenantId;
    r.resourceGroupId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
    r.configurationId = ConfigurationId(data.getString("configurationId"));
    r.ttl = data.getInteger("ttl");

    auto result = usercase.createDeployment(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Deployment created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

    auto deploys = usercase.listDeployments(tenantId, rgId);
    auto jDeploys = deploys.map!(deployment => deployment.toJson).array.toJson;

    auto resp = Json.emptyObject
      .set("count", deploys.length)
      .set("resources", jDeploys);

    return successResponse("Deployment list retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DeploymentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid deployment ID", 400);

    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

    auto deployment = usercase.getDeployment(tenantId, rgId, id);
    if (deployment.isNull)
      return errorResponse("Deployment not found", 404);

    auto responseData = deployment.toJson();
    return successResponse("Deployment retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json patchHandler(HTTPServerRequest req) {
    auto precheck = super.patchHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto id = DeploymentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid deployment ID", 400);

    PatchDeploymentRequest request;
    request.tenantId = tenantId;
    request.resourceGroupId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
    request.deploymentId = id;
    request.targetStatus = data.getString("targetStatus");
    request.configurationId = data.getString("configurationId");
    request.ttl = data.getInteger("ttl");

    auto result = usercase.patchDeployment(request);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Deployment updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DeploymentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid deployment ID", 400);

    auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

    auto result = usercase.deleteDeployment(tenantId, rgId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Deployment deleted successfully", "Deleted", 200, responseData);
  }
}
