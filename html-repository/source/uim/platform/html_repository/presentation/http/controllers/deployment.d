/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.deployment;
// import uim.platform.html_repository.application.usecases.deploy_application;
// import uim.platform.html_repository.application.usecases.get_deployment_history;
// import uim.platform.html_repository.application.dto;
// import uim.platform.htmls;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class DeploymentController : HttpController {
  private DeployApplicationUseCase deployApp;
  private GetDeploymentHistoryUseCase getHistory;

  this(DeployApplicationUseCase deployApp, GetDeploymentHistoryUseCase getHistory) {
    this.deployApp = deployApp;
    this.getHistory = getHistory;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/deployments", &handleCreate);
    router.get("/api/v1/deployments", &handleList);
    router.get("/api/v1/deployments/*", &handleGet);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    ScanJobDTO dto;
    dto.tenantId = tenantId;
    DeployApplicationRequest r;
    r.tenantId = tenantId;
    r.appId = data.getString("appId");
    r.versionId = data.getString("versionId");
    r.serviceInstanceId = data.getString("serviceInstanceId");
    r.operation = data.getString("operation");
    r.deployedBy = data.getString("deployedBy");

    auto result = deployApp.deploy(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto response = Json.emptyObject.set("id", result.id);

    return successResponse("Deployment created successfully", 201, response);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto items = getHistory.getByTenant(tenantId);

    auto arr = Json.emptyArray;
    foreach (e; items) {
      arr ~= Json.emptyObject
        .set("id", e.id)
        .set("appId", e.appId)
        .set("versionId", e.versionId)
        .set("operation", e.operation)
        .set("status", e.status);
    }

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("", 0, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = precheck.id;
    auto tenantId = precheck.tenantId;
    if (id.isNull)
      return errorResponse("Invalid deployment ID", 400);

    auto entry = getHistory.getById(tenantId, id);
    if (entry.isNull)
      return errorResponse("Deployment not found", 404);

    auto response = Json.emptyObject
      .set("id", entry.id)
      .set("appId", entry.appId)
      .set("versionId", entry.versionId)
      .set("serviceInstanceId", entry.serviceInstanceId)
      .set("operation", entry.operation)
      .set("status", entry.status)
      .set("deployedBy", entry.deployedBy)
      .set("deployedAt", entry.deployedAt)
      .set("completedAt", entry.completedAt)
      .set("errorMessage", entry.errorMessage);

    return successResponse("Deployment retrieved successfully", 200, response);
  }
}
