/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_attribute_recommendation.presentation.http.controllers
  .deployment;

// 
// 
// import uim.platform.data_attribute_recommendation.application.usecases.manage.deployments;

// import uim.platform.data_attribute_recommendation.domain.entities.model_deployment;

import uim.platform.data_attribute_recommendation;

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
    router.post("/api/v1/deployments/activate/*", &handleActivate);
    router.post("/api/v1/deployments/deactivate/*", &handleDeactivate);
    router.delete_("/api/v1/deployments/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateDeploymentRequest();
    r.tenantId = tenantId;
    r.trainingJobId = data.getString("trainingJobId");
    r.name = data.getString("name");
    r.replicas = data.getInteger("replicas", 1);
    r.createdBy = UserId(req.headers.get("X-User-Id", "system"));

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
    auto items = usecase.listDeployments(tenantId);

    auto list = items.map!(item => item.toJson()).array.toJson;

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
    if (id.isNull)
      return errorResponse("Invalid deployment ID", 400);

    auto dep = usecase.getDeployment(tenantId, id);
    if (dep.isNull)
      return errorResponse("Deployment not found", 404);

    auto responseData = dep.toJson;
    return successResponse("Deployment retrieved successfully", 200, responseData);
  }

  protected Json activateHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DeploymentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid deployment ID", 400);

    auto result = usecase.activateDeployment(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Deployment activated successfully", 200, responseData);
  }

  protected void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = activateHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json deactivateHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DeploymentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid deployment ID", 400);

    auto result = usecase.deactivateDeployment(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Deployment deactivated successfully", 200, responseData);
  }

  protected void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = deactivateHandler(req);
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
    auto id = DeploymentId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid deployment ID", 400);

    auto result = usecase.deleteDeployment(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Deployment deleted successfully", 200, responseData);
  }
}
