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
class DeploymentController : ManageHttpController {
  protected DeployApplicationUseCase deployApp;
  private GetDeploymentHistoryUseCase history;

  this(DeployApplicationUseCase deployApp, GetDeploymentHistoryUseCase history) {
    this.deployApp = deployApp;
    this.history = history;
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
    CreateDeploymentRequest r;
    r.tenantId = tenantId;
    r.appId = HtmlAppId(data.getString("appId"));
    r.versionId = AppVersionId(data.getString("versionId"));
    r.instanceId = ServiceInstanceId(data.getString("serviceInstanceId"));
    r.operation = data.getString("operation");
    r.deployedBy = UserId(data.getString("deployedBy"));

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
    auto items = history.listRecords(tenantId);

    auto arr = Json.emptyArray;
    foreach (e; items) {
      arr ~= Json.emptyObject
        .set("id", e.id)
        .set("appId", e.appId)
        .set("versionId", e.versionId)
        .set("operation", e.operation.toString())
        .set("status", e.status.toString());
    }

    auto list = items.toJson;

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
    auto id = DeploymentRecordId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid deployment ID", 400);

    auto entry = history.getRecord(tenantId, id);
    if (entry.isNull)
      return errorResponse("Deployment not found", 404);

    auto response = Json.emptyObject
      .set("id", entry.id)
      .set("appId", entry.appId)
      .set("versionId", entry.versionId)
      .set("serviceInstanceId", entry.serviceInstanceId)
      .set("operation", entry.operation.toString())
      .set("status", entry.status.toString())
      .set("deployedBy", entry.deployedBy)
      // .set("deployedAt", entry.deployedAt)
      .set("completedAt", entry.completedAt)
      .set("errorMessage", entry.errorMessage);

    return successResponse("Deployment retrieved successfully", 200, response);
  }
}
