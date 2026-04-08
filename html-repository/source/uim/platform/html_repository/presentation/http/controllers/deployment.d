/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.presentation.http.controllers.deployment;

import uim.platform.html_repository.application.usecases.deploy_application;
import uim.platform.html_repository.application.usecases.get_deployment_history;
import uim.platform.html_repository.application.dto;
import uim.platform.html_repository.presentation.http.json_utils;

import uim.platform.htmls;

import std.conv : to;

class DeploymentController : SAPController {
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
      auto tenantId = req.getTenantId;
      auto items = getHistory.getByTenant(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref e; items) {
        auto obj = Json.emptyObject;
        obj["id"] = Json(e.id);
        obj["appId"] = Json(e.appId);
        obj["versionId"] = Json(e.versionId);
        obj["operation"] = Json(e.operation);
        obj["status"] = Json(e.status);
        arr ~= obj;
      }

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI.to!string);
      auto tenantId = req.getTenantId;
      if (id.length == 0) {
        writeError(res, 404, "Deployment not found");
        return;
      }
      auto entry = getHistory.get_(id, tenantId);
      if (entry is null) {
        writeError(res, 404, "Deployment not found");
        return;
      }
      auto obj = Json.emptyObject;
      obj["id"] = Json(entry.id);
      obj["appId"] = Json(entry.appId);
      obj["versionId"] = Json(entry.versionId);
      obj["serviceInstanceId"] = Json(entry.serviceInstanceId);
      obj["operation"] = Json(entry.operation);
      obj["status"] = Json(entry.status);
      obj["deployedBy"] = Json(entry.deployedBy);
      obj["deployedAt"] = Json(entry.deployedAt);
      obj["completedAt"] = Json(entry.completedAt);
      obj["errorMessage"] = Json(entry.errorMessage);
      res.writeJsonBody(obj, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
