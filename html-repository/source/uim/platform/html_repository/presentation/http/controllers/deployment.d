/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.deployment;

// import uim.platform.html_repository.application.usecases.deploy_application;
// import uim.platform.html_repository.application.usecases.get_deployment_history;
// import uim.platform.html_repository.application.dto;
// import uim.platform.html_repository.presentation.http.json_utils;

// import uim.platform.htmls;

// import std.conv : to;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class DeploymentController : PlatformController {
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      DeployApplicationRequest r;
      r.tenantId = req.getTenantId;
      r.appId = j.getString("appId");
      r.versionId = j.getString("versionId");
      r.serviceInstanceId = j.getString("serviceInstanceId");
      r.operation = j.getString("operation");
      r.deployedBy = j.getString("deployedBy");

      auto result = deployApp.deploy(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
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

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI.to!string);
      TenantId tenantId = req.getTenantId;
      if (Id.isEmpty) {
        writeError(res, 404, "Deployment not found");
        return;
      }
      auto entry = getHistory.getById(tenantId, id);
      if (entry is null) {
        writeError(res, 404, "Deployment not found");
        return;
      }
      
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

      res.writeJsonBody(obj, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
