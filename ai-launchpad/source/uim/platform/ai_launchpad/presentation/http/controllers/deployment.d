/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_launchpad.presentation.http.controllers.deployment;

// import uim.platform.ai_launchpad.application.usecases.manage.deployments;
// import uim.platform.ai_launchpad.application.dto;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

class DeploymentController : ManageController {
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

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      CreateDeploymentRequest r;
      r.tenantId = tenantId;
      r.connectionId = connectionId;
      r.configurationId = j.getString("configurationId");
      r.resourceGroupId = j.getString("resourceGroupId");
      r.ttl = j.getInteger("ttl");

      auto result = usecase.createDeployment(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Deployment created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
      auto scenarioId = ScenarioId(req.headers.get("X-Scenario-Id", ""));

      auto deployments = scenarioId.isEmpty
        ? usecase.listDeployments(tenantId, connectionId)
        : usecase.listDeployments(tenantId, connectionId, scenarioId);

      auto jarr = deployments.map!(d => d.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("count", Json(deployments.length))
        .set("resources", jarr)
        .set("message", "Deployments retrieved");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = DeploymentId(extractIdFromPath(req.requestURI.to!string));
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      auto d = usecase.getDeployment(tenantId, connectionId, id);
      if (d.isNull) {
        writeError(res, 404, "Deployment not found");
        return;
      }

      auto resp = d.toJson
        .set("message", "Deployment retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = DeploymentId(extractIdFromPath(req.requestURI.to!string));
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
      auto j = req.json;

      PatchDeploymentRequest r;
      r.tenantId = tenantId;
      r.connectionId = connectionId;
      r.deploymentId = id;
      r.targetStatus = j.getString("targetStatus");
      r.configurationId = j.getString("configurationId");
      r.ttl = j.getInteger("ttl");

      auto result = usecase.patchDeployment(r);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Deployment updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleBulkPatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      BulkPatchDeploymentRequest r;
      r.tenantId = tenantId;
      r.connectionId = connectionId;
      r.deploymentIds = getStrings(j, "deploymentIds").map!(id => DeploymentId(id)).array;
      r.targetStatus = j.getString("targetStatus");

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

      auto resp = Json.emptyObject
        .set("results", jarr)
        .set("message", "Bulk deployment update completed");
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = DeploymentId(extractIdFromPath(req.requestURI.to!string));
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      auto result = usecase.deleteDeployment(tenantId, connectionId, id);
      if (result.hasError)
            return errorResponse(result.message, 400);
        auto resp = Json.emptyObject
          .set("message", "Deployment deleted successfully"); 
          
        res.writeJsonBody(resp, 204);
      } else {
        writeError(res, 404, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }


}
