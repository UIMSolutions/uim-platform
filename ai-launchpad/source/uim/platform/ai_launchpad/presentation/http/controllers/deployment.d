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

class DeploymentController : PlatformController {
  private ManageDeploymentsUseCase uc;

  this(ManageDeploymentsUseCase uc) {
    this.uc = uc;
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

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      CreateDeploymentRequest r;
      r.connectionId = connectionId;
      r.configurationId = j.getString("configurationId");
      r.resourceGroupId = j.getString("resourceGroupId");
      r.ttl = j.getInteger("ttl");

      auto result = uc.create(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Deployment created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));
      auto scenarioId = ScenarioId(req.headers.get("X-Scenario-Id", ""));

      typeof(uc.listByConnection(connectionId)) deployments;
      deployments = scenarioId.length > 0
        ? uc.listByScenario(scenarioId, connectionId) : uc.listByConnection(connectionId);

      auto jarr = deployments.map!(d => d.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("count", Json(deployments.length))
        .set("resources", jarr);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      auto d = uc.getById(id, connectionId);
      if (d.isNull) {
        writeError(res, 404, "Deployment not found");
        return;
      }

      res.writeJsonBody(d.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto j = req.json;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      PatchDeploymentRequest r;
      r.connectionId = connectionId;
      r.deploymentId = id;
      r.targetStatus = j.getString("targetStatus");
      r.configurationId = j.getString("configurationId");
      r.ttl = j.getInteger("ttl");

      auto result = uc.patch(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Deployment updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleBulkPatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      BulkPatchDeploymentRequest r;
      r.connectionId = connectionId;
      r.deploymentIds = getStringArray(j, "deploymentIds");
      r.targetStatus = j.getString("targetStatus");

      auto results = uc.bulkPatch(r);
      auto jarr = Json.emptyArray;
      foreach (result; results) {
        auto rj = Json.emptyObject
          .set("id", Json(result.id))
          .set("success", Json(result.success));

        if (result.error.length > 0)
          rj = rj.set("error", Json(result.error));
        jarr ~= rj;
      }

      auto resp = Json.emptyObject
        .set("results", jarr);
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      import std.conv : to;

      auto id = extractIdFromPath(req.requestURI.to!string);
      auto connectionId = ConnectionId(req.headers.get("X-Connection-Id", ""));

      auto result = uc.remove(id, connectionId);
      if (result.success) {
        res.writeJsonBody(Json.emptyObject, 204);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }


}
