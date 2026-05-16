/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.presentation.http.controllers.deployment;
// import uim.platform.ai_core.application.usecases.manage.deployments;
// import uim.platform.ai_core.application.dto;
// import uim.platform.ai_core;
import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
class DeploymentController : PlatformController {
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

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      CreateDeploymentRequest r;
      r.tenantId = tenantId;
      r.resourceGroupId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
      r.configurationId = ConfigurationId(j.getString("configurationId"));
      r.ttl = j.getInteger("ttl");

      auto result = usercase.createDeployment(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Deployment scheduled")
          .set("status", "PENDING");

        res.writeJsonBody(resp, 202);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
      
      auto deploys = usercase.listDeployments(tenantId, rgId);
      auto jDeploys = deploys.map!(deployment => deployment.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("count", deploys.length)
        .set("resources", jDeploys)
        .set("message", "Deployments retrieved");
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;  
      auto id = DeploymentId(extractIdFromPath(req.requestURI.to!string));
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));

      auto deployment = usercase.getDeployment(tenantId, rgId, id);
      if (deployment.isNull) {
        writeError(res, 404, "Deployment not found");
        return;
      }

      res.writeJsonBody(deployment.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = DeploymentId(extractIdFromPath(req.requestURI.to!string));
      
      auto j = req.json;
      PatchDeploymentRequest request;
      request.tenantId = tenantId;
      request.resourceGroupId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
      request.deploymentId = id;
      request.targetStatus = j.getString("targetStatus");
      request.configurationId = j.getString("configurationId");
      request.ttl = j.getInteger("ttl");

      auto result = usercase.patchDeployment(request);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Deployment modified");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto rgId = ResourceGroupId(req.headers.get("AI-Resource-Group", ""));
      auto id = DeploymentId(extractIdFromPath(req.requestURI.to!string));

      auto result = usercase.deleteDeployment(tenantId, rgId, id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("status", "deleted")
          .set("message", "Deployment deleted");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
