/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.attribute_recommendation.presentation.http.controllers
  .deployment_controller;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.data.attribute_recommendation.application.usecases.manage.deployments;
// import uim.platform.data.attribute_recommendation.application.dto;
// import uim.platform.data.attribute_recommendation.domain.entities.model_deployment;
// import uim.platform.data.attribute_recommendation.domain.types;
import uim.platform.data.attribute_recommendation;

mixin(ShowModule!());
@safe:
class DeploymentController : PlatformController {
  private ManageDeploymentsUseCase uc;

  this(ManageDeploymentsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/deployments", &handleCreate);
    router.get("/api/v1/deployments", &handleList);
    router.get("/api/v1/deployments/*", &handleGetById);
    router.post("/api/v1/deployments/activate/*", &handleActivate);
    router.post("/api/v1/deployments/deactivate/*", &handleDeactivate);
    router.delete_("/api/v1/deployments/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateDeploymentRequest();
      r.tenantId = req.getTenantId;
      r.trainingJobId = j.getString("trainingJobId");
      r.name = j.getString("name");
      r.replicas = j.getInteger("replicas", 1);
      r.createdBy = req.headers.get("X-User-Id", "system");

      auto result = uc.createDeployment(r);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", "Deployment created successfully");

        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto items = uc.listDeployments(tenantId);

      auto arr = items.map!(d => d.toJson).array.toJson;

      auto resp = Json.emptyObject
            .set("items", arr)
            .set("totalCount", Json(items.length))
            .set("message", "Deployments retrieved successfully");

      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto dep = uc.getDeployment(tenantId, id);
      if (dep is null) {
        writeError(res, 404, "Deployment not found");
        return;
      }
      res.writeJsonBody(dep.toJson, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleActivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = uc.activateDeployment(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("status", Json("active"))
            .set("message", "Deployment activated successfully");

        res.writeJsonBody(resp, 200);
      }
      else
      {
        auto status = result.error == "Deployment not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDeactivate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = uc.deactivateDeployment(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject  
            .set("id", Json(result.id))
            .set("status", Json("inactive"))
            .set("message", "Deployment deactivated successfully");

        res.writeJsonBody(resp, 200);
      }
      else
      {
        auto status = result.error == "Deployment not found" ? 404 : 400;
        writeError(res, status, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = uc.deleteDeployment(tenantId, id);
      if (result.isSuccess) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("deleted", true)
            .set("message", "Deployment deleted successfully");
            
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeDeployment(const ModelDeployment d) {
    return Json.emptyObject
      .set("id", d.id)
      .set("tenantId", d.tenantId)
      .set("trainingJobId", d.trainingJobId)
      .set("modelConfigId", d.modelConfigId)
      .set("name", d.name)
      .set("status", d.status.to!string)
      .set("endpointUrl", d.endpointUrl)
      .set("version", d.version_)
      .set("replicas", d.replicas)
      .set("createdBy", d.createdBy)
      .set("createdAt", d.createdAt)
      .set("updatedAt", d.updatedAt);
  }
}
